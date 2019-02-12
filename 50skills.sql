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

-- 17、按平均成绩从高到低显示所有学生的“数据库”、“企业管理”、“英语”三门的课程成绩，按如下形式显示： 学生ID,,数据库,企业管理,英语,有效课程数,有效平均分

select StuId,stuName ,
(select score from tblscore sc INNER JOIN tblcourse co  on sc.courseid = co.courseid where co.courseName = '数据库' AND sc.stuid = st.stuid) AS '数据库',
(select score from tblscore sc INNER JOIN tblcourse co  on sc.courseid = co.courseid where co.courseName = '企业管理' AND sc.stuid = st.stuid) AS '企业管理',
(select score from tblscore sc INNER JOIN tblcourse co  on sc.courseid = co.courseid where co.courseName = '英语' AND sc.stuid = st.stuid) AS '英语',
(select avg(score) from tblscore sc where sc.stuid = st.stuid) AS 有效平均分
from tblstudent st
ORDER BY 有效平均分 DESC

Select StuId
  ,(Select Score From tblScore sc Inner Join tblCourse cs On sc.CourseId=cs.CourseId Where CourseName='数据库' And sc.StuID=st.StuId) 数据库
  ,(Select Score From tblScore sc Inner Join tblCourse cs On sc.CourseId=cs.CourseId Where CourseName='企业管理' And sc.StuID=st.StuId) 企业管理
  ,(Select Score From tblScore sc Inner Join tblCourse cs On sc.CourseId=cs.CourseId Where CourseName='英语' And sc.StuID=st.StuId) 语
  ,(Select Count(Score) From tblScore sc Inner Join tblCourse cs On sc.CourseId=cs.CourseId Where (CourseName='数据库' or CourseName='企业管理' or CourseName='英语') And sc.StuID=st.StuId) 有效课程数
  ,(Select Avg(Score) From tblScore sc Inner Join tblCourse cs On sc.CourseId=cs.CourseId Where (CourseName='数据库' or CourseName='企业管理' or CourseName='英语') And sc.StuID=st.StuId) 有效平均分
  From tblStudent st
  Order by 有效平均分 Desc



--18、查询各科成绩最高和最低的分：以如下形式显示：课程ID，最高分，最低分 

select CourseId,MAX(Score) 最高分,MIN(Score) 最低分 
from tblscore GROUP BY CourseId

 Select CourseId as 课程ID, (Select Max(Score) From tblScore sc Where sc.CourseId=cs.CourseId ) 最高分,
  (Select Min(Score) From tblScore sc Where sc.CourseId=cs.CourseId ) 最低分
  From tblCourse cs


--19、按各科平均成绩从低到高和及格率的百分数从高到低顺序 (百分数后如何格式化为两位小数??)

select CourseId,
(Select Avg(Score) From tblScore sc Where sc.CourseId=cs.CourseId ) 平均分,
CONCAT(ROUND((select COUNT(b.StuId) from tblscore b where b.CourseId = cs.CourseId AND b.score >= 60)/(select COUNT(c.StuId) from tblscore c WHERE c.CourseId = cs.CourseId)*100,2),'%') 及格率
from tblscore cs


--查询如下课程平均成绩和及格率的百分数(用"1行"显示): 企业管理（001），马克思（002），OO&UML （003），数据库（004） 

Select sc.CourseId 课程ID,cs.CourseName 课程名称,Avg(Score) 平均成绩,
	CONCAT(ROUND(((Select Count(Score) From tblScore Where CourseId=sc.CourseId And Score>=60)*10000/Count(Score))/100.0,2),'%') 及格率 
  From tblScore sc
  Inner Join tblCourse cs ON sc.CourseId=cs.CourseId
  Where sc.CourseId like '00%'
  Group By sc.CourseId,cs.CourseName



