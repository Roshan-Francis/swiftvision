In mysql create 2 tables 

create tables students (
    rollno int  primary key ,name varchar(20), course varchar(20) , department varchar (20)
);

CREATE TABLE attendance (
    rollno VARCHAR(20) references students(rollno)
);


In firestore create 2 collections 

students
|
|___<rollno>
|    |___name        : ""
|    |___department  : ""
|    |___course      : ""
|
|
|___<rollno>
    |
    |___rollno      : ""
    |___name        : ""
    |___department  : ""
    |___course      : ""


attendance
|
|___<rollno>
|    |
|    |__<date> : ""  // present or absent
|
|
|___<rollno>
    |
    |__<date> : ""  // present or absent
    