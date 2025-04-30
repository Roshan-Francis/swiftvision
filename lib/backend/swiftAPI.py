import os
import cv2
import numpy as np
import time
from datetime import datetime
from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
import mysql.connector
import firebase_admin
from firebase_admin import credentials, firestore
from mtcnn import MTCNN
import face_recognition

# Initialize Flask app
app = Flask(__name__)

# Initialize Firebase Admin
cred = credentials.Certificate('path/to/your/firebase/credentials.json')
firebase_admin.initialize_app(cred)
firestore_db = firestore.client()

# MySQL connection
def get_db_connection():
    return mysql.connector.connect(
        host='your_host',
        user='your_username',
        password='your_password',
        database='your_database'
    )

# Student photos folder
UPLOAD_FOLDER = 'students'
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

# MTCNN setup
detector = MTCNN()

# --- Helper functions ---
def detect_and_encode_faces(image):
    image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    results = detector.detect_faces(image_rgb)
    face_encodings = []

    for result in results:
        x, y, width, height = result['box']
        x, y = max(0, x), max(0, y)
        face_crop = image[y:y+height, x:x+width]
        face_crop_rgb = cv2.cvtColor(face_crop, cv2.COLOR_BGR2RGB)
        encodings = face_recognition.face_encodings(face_crop_rgb, num_jitters=10)
        if encodings:
            face_encodings.append(encodings[0])

    return face_encodings

def load_student_encodings():
    encodings = {}
    for filename in os.listdir(UPLOAD_FOLDER):
        if filename.endswith('.jpg') or filename.endswith('.png'):
            student_rollno = filename.split('.')[0]
            path = os.path.join(UPLOAD_FOLDER, filename)
            img = cv2.imread(path)
            encoding = detect_and_encode_faces(img)
            if encoding:
                encodings[student_rollno] = encoding
    return encodings

def recognize_faces(photo_path):
    img = cv2.imread(photo_path)
    input_encodings = detect_and_encode_faces(img)
    if not input_encodings:
        return None

    student_encodings = load_student_encodings()
    recognized_rollnos = []

    for input_encoding in input_encodings:
        for rollno, stored_encodings in student_encodings.items():
            matches = face_recognition.compare_faces(stored_encodings, input_encoding, tolerance=0.5)
            if any(matches):
                recognized_rollnos.append(rollno)
                break

    return recognized_rollnos

def create_today_column_if_not_exists(cursor):
    today_date = datetime.now().strftime('%d_%m_%Y')
    column_name = f"`{today_date}`"
    cursor.execute("SHOW COLUMNS FROM attendance LIKE %s", (today_date,))
    result = cursor.fetchone()
    if not result:
        cursor.execute(f"ALTER TABLE attendance ADD COLUMN {column_name} VARCHAR(10) DEFAULT 'ABSENT'")
    return today_date

def mark_present(cursor, rollno, today_date):
    today_col = f"`{today_date}`"
    cursor.execute(f"UPDATE attendance SET {today_col} = 'PRESENT' WHERE rollno = %s", (rollno,))

def mark_present_in_firestore(rollno, today_date):
    attendance_ref = firestore_db.collection('attendance').document(rollno)
    doc = attendance_ref.get()
    if not doc.exists:
        attendance_ref.set({today_date: 'PRESENT'})
    else:
        attendance_ref.update({today_date: 'PRESENT'})

# --- Routes ---

# 1. Register student
@app.route('/register_student', methods=['POST'])
def register_student():
    try:
        rollno = request.form['rollno']
        name = request.form['name']
        course = request.form['course']
        department = request.form['department']
        photo = request.files['photo']

        if photo.content_type not in ['image/jpeg', 'image/png']:
            return jsonify({"message": "Invalid file type. Only JPG and PNG allowed."}), 400

        photo_filename = f"{rollno}.jpg"
        photo_path = os.path.join(UPLOAD_FOLDER, photo_filename)
        photo.save(photo_path)

        conn = get_db_connection()
        cursor = conn.cursor()
        sql = "INSERT INTO students (rollno, name, course, department) VALUES (%s, %s, %s, %s)"
        values = (rollno, name, course, department)
        cursor.execute(sql, values)
        conn.commit()
        cursor.close()
        conn.close()

        student_data = {
            "rollno": rollno,
            "name": name,
            "course": course,
            "department": department
        }
        firestore_db.collection("students").document(rollno).set(student_data)

        return jsonify({"message": "Student registered successfully"}), 200

    except mysql.connector.Error as e:
        return jsonify({"message": "Database error", "error": str(e)}), 500
    except Exception as e:
        return jsonify({"message": "Failed to register student", "error": str(e)}), 500

# 2. Mark attendance
@app.route('/attendance', methods=['POST'])
def mark_attendance():
    if 'photo' not in request.files:
        return jsonify({'message': 'No photo uploaded'}), 400

    photo = request.files['photo']
    if photo.filename == '':
        return jsonify({'message': 'No photo selected'}), 400

    filename = secure_filename(photo.filename)
    temp_folder = 'temp'
    if not os.path.exists(temp_folder):
        os.makedirs(temp_folder)
    photo_path = os.path.join(temp_folder, filename)
    photo.save(photo_path)

    recognized_rollnos = recognize_faces(photo_path)
    os.remove(photo_path)

    if recognized_rollnos:
        today_date = datetime.now().strftime('%d_%m_%Y')

        for student_rollno in recognized_rollnos:
            mark_present_in_firestore(student_rollno, today_date)

        conn = get_db_connection()
        cursor = conn.cursor()
        today_date = create_today_column_if_not_exists(cursor)

        for student_rollno in recognized_rollnos:
            cursor.execute("SELECT rollno FROM attendance WHERE rollno = %s", (student_rollno,))
            if cursor.fetchone() is None:
                cursor.execute("INSERT INTO attendance (rollno) VALUES (%s)", (student_rollno,))
            mark_present(cursor, student_rollno, today_date)

        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({'message': f'Attendance marked PRESENT for roll numbers: {", ".join(recognized_rollnos)}'}), 200
    else:
        return jsonify({'message': 'No matching students found'}), 404

# 3. View all attendance
@app.route('/view_all_attendance', methods=['GET'])
def view_all_attendance():
    attendance_ref = firestore_db.collection('attendance')
    attendance_documents = attendance_ref.stream()
    result = []
    dates = []

    students_ref = firestore_db.collection('students')

    for attendance_doc in attendance_documents:
        rollno = attendance_doc.id
        student_doc = students_ref.document(rollno).get()

        if not student_doc.exists:
            continue

        attendance_data = attendance_doc.to_dict()

        for date, status in attendance_data.items():
            if date != 'date' and date not in dates:
                dates.append(date)

        student_record = {'rollno': rollno}
        for date in dates:
            student_record[date] = attendance_data.get(date, 'ABSENT')

        result.append(student_record)

    return jsonify({'dates': dates, 'attendance': result})

# 4. View attendance by roll number
@app.route('/view_attendance_by_rollno/<rollno>', methods=['GET'])
def view_attendance_by_rollno(rollno):
    students_ref = firestore_db.collection('students')
    student_doc = students_ref.document(rollno).get()

    if not student_doc.exists:
        return jsonify({'message': 'Roll number not found'}), 404

    attendance_doc = firestore_db.collection('attendance').document(rollno).get()

    if not attendance_doc.exists:
        return jsonify({'message': 'No attendance records found for this roll number'}), 404

    attendance_data = attendance_doc.to_dict()
    result = {'rollno': rollno}
    dates = []

    for date, status in attendance_data.items():
        if date != 'date':
            dates.append(date)
            result[date] = status

    return jsonify({'dates': dates, 'attendance': [result]})

# --- Run the app ---
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
