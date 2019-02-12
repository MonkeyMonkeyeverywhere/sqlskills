-- 2、查询平均成绩大于60分的同学的学号和平均成绩；
select stuId,avg(score) from tblscore GROUP BY StuId HAVING avg(score) > 60

-- 3、查询所有同学的学号、姓名、选课数、总成绩； 
select 
StuId,
stuName,
(select COUNT(1) FROM tblscore t2 where t2.StuId = t1.stuId ) as '选课数',
(select sum(score) from tblscore t3 where t3.StuId = t1.stuId) as '总成绩'
 FROM tblstudent t1

-- 4、查询姓“李”的老师的个数；
select count(teaId) from tblteacher where teaName like '李%'

-- 5、查询没学过“叶平”老师课的同学的学号、姓名；
SELECT StuId,stuName from tblstudent where StuId NOT in (
select StuId from tblscore where CourseId in 
(select a.CourseId from tblcourse a INNER JOIN tblteacher b on a.teaId = b.teaId  where b.teaName = '叶平')
)

-- 6、查询学过“001”并且也学过编号“002”课程的同学的学号、姓名；

select StuId,stuName from tblstudent a where 
EXISTS (select StuId from tblscore where CourseId = '001' AND StuId = a.stuId )
AND EXISTS (select StuId from tblscore where CourseId = '002' AND StuId = a.stuId ) 


Select StuId,StuName From tblStudent st
  Where (Select Count(*) From tblScore s1 Where s1.StuId=st.StuId And s1.CourseId='001')>0
   And
   (Select Count(*) From tblScore s2 Where s2.StuId=st.StuId And s2.CourseId='002')>0


-- 7、查询学过“叶平”老师所教的所有课的同学的学号、姓名；

select StuId,stuName from tblstudent st where NOT EXISTS(
select * from tblcourse a INNER JOIN tblteacher b on a.teaId = b.teaId WHERE b.teaName = '叶平' and CourseId not in (select CourseId from tblscore where StuId = st.stuId)
)
-- 9、查询所有课程成绩小于60分的同学的学号、姓名；
select stuid,stuname from tblstudent a where StuId not in 
(
		select StuId from tblscore where StuId = a.StuId and score > 60 
)


-- 10、查询没有学全所有课的同学的学号、姓名；
select stuid,stuname from tblstudent a where 
(select COUNT(courseId) from tblscore where StuId = a.StuId ) <
(select COUNT(courseId) from tblcourse)


-- 11、查询至少有一门课与学号为“1001”的同学所学相同的同学的学号和姓名；
 -- ----运用连接查询

select DISTINCT a.StuId,a.StuName from tblstudent a INNER JOIN tblscore b on a.StuId = b.stuid 
where b.courseId in (select courseId from tblscore where StuId = '1001')

-- 扩展：每人选了多少门课
select a.StuName,COUNT(b.stuId) from tblstudent a left JOIN tblscore b on a.StuId = b.stuid 
GROUP BY a.StuId

 -- ----嵌套子查询

select StuId,StuName from tblstudent a 
where EXISTS
(select courseId from tblscore WHERE StuId = a.StuId AND courseId in (select courseId from tblscore where StuId = '1001')) 


Select StuId,StuName From tblStudent
  Where StuId In
  (
   Select Distinct StuId From tblScore Where CourseId In (Select CourseId From tblScore Where StuId='1001')
  )

-- 12、查询至少学过学号为“1001”同学所有课程的其他同学学号和姓名；

select StuId,StuName from tblstudent where StuId in (select StuId from tblscore where courseId in (select courseid from tblscore where stuid = '1001'))

-- 学过1001所有的课程
select StuId,StuName from tblstudent a where 
(select COUNT(courseid) from tblscore where StuId = a.StuId) > (select COUNT(courseid) from tblscore where StuId = '1001') AND
EXISTS (select courseId from tblscore where StuId = a.StuId AND courseId not in (select courseId from tblscore where StuId = '1001'))



-- 14、查询和“1002”号的同学学习的课程完全相同的其他同学学号和姓名；  

select StuId,StuName from tblstudent a 
Where StuId <> '1002' AND
NOT EXISTS (select courseId from tblscore where StuId = a.StuId AND courseId not in (select courseId from tblscore where StuId = '1002'))
AND NOT EXISTS (select courseId from tblscore where StuId = '1002' AND courseId not in (select courseId from tblscore where StuId = a.StuId))

-- 16、向SC表中插入一些记录，这些记录要求符合以下条件：没有上过编号“003”课程的同学学号、'002'号课的平均成绩； 

delete from tblscore where score BETWEEN 79 AND 80

INSERT INTO tblscore (StuId,courseId,score) 
select DISTINCT StuId,'003',(select AVG(score) from tblscore where courseid = '002' ) from tblscore where StuId NOT in (select StuId from tblscore where courseId = '003')
