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


--20查询如下课程平均成绩和及格率的百分数(用"1行"显示): 企业管理（001），马克思（002），OO&UML （003），数据库（004） 

Select sc.CourseId 课程ID,cs.CourseName 课程名称,Avg(Score) 平均成绩,
	CONCAT(ROUND(((Select Count(Score) From tblScore Where CourseId=sc.CourseId And Score>=60)*10000/Count(Score))/100.0,2),'%') 及格率 
  From tblScore sc
  Inner Join tblCourse cs ON sc.CourseId=cs.CourseId
  Where sc.CourseId like '00[1234]'
  Group By sc.CourseId,cs.CourseName

--21、查询不同老师所教不同课程平均分从高到低显示

select
 c.teaid,c.teaname,b.coursename,avg(score) 平均分
FROM tblscore a 
INNER JOIN tblcourse b on a.courseid = b.courseid
INNER JOIN tblteacher c on b.teaid = c.teaid
GROUP BY c.teaid,c.teaName,b.coursename
ORDER BY 平均分 DESC

 Select CourseId 课程ID,CourseName 课程名称,TeaName 授课教师,(Select Avg(Score) From tblScore Where CourseId=cs.CourseId) 平均成绩
  From tblCourse cs
  Inner Join tblTeacher tc ON cs.TeaId=tc.TeaId
  Order by 平均成绩 Desc



--22、查询如下课程成绩第 3 名到第 6 名的学生成绩单：企业管理（001），马克思（002），UML （003），数据库（004） 格式：[学生ID],[学生姓名],企业管理,马克思,UML,数据库,平均成绩

select temp.stuid,st.stuname
from
(
(select stuid,cu.coursename,score from tblscore sc INNER JOIN tblcourse cu on sc.courseid = cu.courseid where cu.coursename = '企业管理' LIMIT 2,3)
UNION 
(select stuid,cu.coursename,score from tblscore sc INNER JOIN tblcourse cu on sc.courseid = cu.courseid where cu.coursename = '马克思' LIMIT 2,3)
UNION
(select stuid,cu.coursename,score from tblscore sc INNER JOIN tblcourse cu on sc.courseid = cu.courseid where cu.coursename = 'UML' LIMIT 2,3)
UNION
(select stuid,cu.coursename,score from tblscore sc INNER JOIN tblcourse cu on sc.courseid = cu.courseid where cu.coursename = '数据库' LIMIT 2,3)
) as temp INNER JOIN tblstudent st on temp.stuid = st.stuid
^^^^^^^^^^^^^未能实现要求

Select * From 
  (
   Select Top 6 StuId 学生ID,StuName 学生姓名
    ,(Select Score From tblScore sc Inner Join tblCourse cs On sc.CourseId=cs.CourseId Where CourseName='企业管理' And sc.StuID=st.StuId) 企业管理
    ,(Select Score From tblScore sc Inner Join tblCourse cs On sc.CourseId=cs.CourseId Where CourseName='马克思' And sc.StuID=st.StuId) 马克思
    ,(Select Score From tblScore sc Inner Join tblCourse cs On sc.CourseId=cs.CourseId Where CourseName='UML' And sc.StuID=st.StuId) UML
    ,(Select Score From tblScore sc Inner Join tblCourse cs On sc.CourseId=cs.CourseId Where CourseName='数据库' And sc.StuID=st.StuId) 数据库
    ,(Select Avg(Score) From tblScore sc Inner Join tblCourse cs On sc.CourseId=cs.CourseId Where (CourseName='数据库' or CourseName='企业管理' or CourseName='UML'or CourseName='马克思') And sc.StuID=st.StuId) 平均成绩
    ,Row_Number() Over(Order by(Select Avg(Score) From tblScore sc Inner Join tblCourse cs On sc.CourseId=cs.CourseId Where (CourseName='数据库' or CourseName='企业管理' or CourseName='UML'or CourseName='马克思') And sc.StuID=st.StuId) DESC) 排名
    From tblStudent st
    Order by 排名
  ) as tmp
  Where 排名 between 3 And 6


--23、统计列印各科成绩,各分数段人数:课程ID,课程名称,[100-85],[85-70],[70-60],[ <60] 

select courseid 课程ID,coursename 课程名称,
 (select COUNT(*) from tblscore where courseid = cs.courseid and score BETWEEN 85 AND 100) AS '[100-85]',
 (select COUNT(*) from tblscore where courseid = cs.courseid and score BETWEEN 70 AND 85) AS '[85-70]',
 (select COUNT(*) from tblscore where courseid = cs.courseid and score BETWEEN 60 AND 70) AS '[70-60]',
 (select COUNT(*) from tblscore where courseid = cs.courseid and score BETWEEN 0 AND 60) AS '[<60]'
from tblcourse cs

--24、查询学生平均成绩及其名次 

select stuid,avg(score) avgscore from tblscore GROUP BY stuid
^^^^排名


--25、查询各科成绩前三名的记录:(不考虑成绩并列情况)


--26、查询每门课程被选修的学生数 

select coursename,
 (select COUNT(*) from tblscore where courseid = cs.courseid) 选修人数
from tblcourse cs


--27、查询出只选修了一门课程的全部学生的学号和姓名 

select stuid,stuname from tblstudent st where 
(select COUNT(*) from tblscore where stuid = st.stuid) = 1
 
--28、查询男生、女生人数 
select 
(select COUNT(*) from tblstudent where stusex = '男') 男生人数,
(select COUNT(*) from tblstudent where stusex = '女') 女生人数

--29、查询姓“张”的学生名单 

select * from tblstudent where stuname like '张%'


--30、查询同名同性学生名单，并统计同名人数 
 Select Distinct StuName 学生姓名,(Select Count(*) From tblStudent s2 Where s2.StuName=st.StuName) 同名人数 From tblStudent st
  Where (Select Count(*) From tblStudent s2 Where s2.StuName=st.StuName)>=2


--32、查询每门课程的平均成绩，结果按平均成绩升序排列，平均成绩相同时，按课程号降序排列 

select coursename,
(select avg(score) from tblscore where courseid = cs.courseid) 平均成绩
from tblcourse cs 
ORDER BY 平均成绩 ASC,courseid DESC

--33、查询平均成绩大于85的所有学生的学号、姓名和平均成绩 

select stuid,stuname,(select avg(score) from tblscore where stuid = st.stuid) 平均成绩 from tblstudent st where 平均成绩 > 85 --不行


select stuid,stuname from tblstudent st where (select avg(score) from tblscore where stuid = st.stuid) > 85  --不行

   --呃呃呃就是子查询两次啊，，太low了吧
Select StuId 学号,StuName 姓名,(Select Avg(Score) From tblScore Where StuId=st.StuId) 平均成绩 From tblStudent st
  Where (Select Avg(Score) From tblScore Where StuId=st.StuId)>85


--34、查询课程名称为“数据库”，且分数低于60的学生姓名和分数 
  
--垃圾方法
select stuname ,
(select score from tblscore sr INNER JOIN tblcourse cr on sr.courseid = cr.courseid where stuid = st.stuid and cr.coursename = '数据库') 数据库
from tblstudent st 
where (select score from tblscore sr INNER JOIN tblcourse cr on sr.courseid = cr.courseid where stuid = st.stuid and cr.coursename = '数据库')<60

 Select StuName 姓名,Score 分数 From tblScore sc
  Inner Join tblStudent st On sc.StuId=st.StuId
  Inner Join tblCourse cs On sc.CourseId=cs.CourseId
  Where CourseName='数据库' And Score<60

--35、查询所有学生的选课情况； 
EXPLAIN
 Select StuId 学号,(Select count(DISTINCT courseid) From tblScore Where StuId=st.StuId) 选课数
  From tblStudent st

-- （上面的）扩展：每人选了多少门课
EXPLAIN
select a.StuName,COUNT(b.stuId) from tblstudent a left JOIN tblscore b on a.StuId = b.stuid 
GROUP BY a.StuId


--36、查询任何一门课程成绩在70分以上的姓名、课程名称和分数； 
select 
st.stuname,c.coursename,sc.score
from tblscore sc INNER JOIN tblstudent st on sc.stuid = st.stuid 
INNER JOIN tblcourse c on sc.courseid = c.courseid
where sc.score > 70


--38、查询课程编号为003且课程成绩在80分以上的学生的学号和姓名；
EXPLAIN
select stuid,stuname from tblstudent where stuid in (select DISTINCT stuid from tblscore where courseid = '003' and score > 80)


--40、查询选修“叶平”老师所授课程的学生中，成绩最高的学生姓名及其成绩 
EXPLAIN
Select CourseId,CourseName
 ,(Select StuName From tblStudent Where StuId in (Select StuID From tblScore Where CourseId=cs.CourseId Order by Score Desc) limit 1) 该科最高学生
 ,(Select Score From tblScore Where CourseId=cs.CourseId Order by Score Desc limit 1) 成绩
 From tblCourse cs Inner Join tblTeacher tc ON cs.TeaId=tc.TeaId
 Where TeaName='叶平'


--41、查询各个课程及相应的选修人数 

select 
coursename,
(select count(stuid) from tblscore where courseid = cs.courseid) 选修人数
from tblcourse cs 


--42、查询不同课程成绩相同的 学生的学号、课程号、学生成绩 
 Select StuId 学号, CourseId 课程号, Score 成绩 From tblScore sc 
  Where Exists (Select * From tblScore Where Score=sc.Score And StuId=sc.StuId And CourseId <>sc.CourseId)
  Order by 学号,成绩

--43、查询每门功成绩最好的前两名 

select
coursename, 
(select stuid from tblscore where courseid = cs.courseid ORDER BY score desc LIMIT 1) 第一名,
(select stuid from tblscore where courseid = cs.courseid ORDER BY score desc LIMIT 1,1) 第二名
from tblcourse cs 


--44、统计每门课程的学生选修人数（超过10人的课程才统计）。要求输出课程号和选修人数，查询结果按人数降序排列，若人数相同，按课程号升序排列  

Select CourseId 课程ID,(Select count(Distinct StuId) From tblScore Where CourseId=cs.CourseId) 选修人数
  From tblCourse cs 
  Where (Select count(Distinct StuId) From tblScore Where CourseId=cs.CourseId)>=10
  Order by 选修人数 DESC, 课程ID  


--45、检索至少选修两门课程的学生学号 

select 
stuid
from tblscore GROUP BY stuid
HAVING COUNT(courseid) > 1   --没有重复选课


--有重复课程时用此方法(如补考)

select 
stuid
from tblscore GROUP BY stuid
HAVING COUNT(DISTINCT courseid) > 1


--46、查询全部学生都选修的课程的课程号和课程名 
select 
courseid,coursename
from tblcourse cs
where not EXISTS --没学过本课程的学生是否存在
(select stuid from tblstudent where stuid not in (select stuid from tblscore where courseid = cs.courseid) )

--48、查询两门以上不及格课程的同学的学号及其平均成绩 

Select StuID as 学号,Avg(Score) as 平均成绩 
From tblScore sc
  Where (Select Count(*) From tblScore s1 Where s1.StuId=sc.StuId And Score<60)>=2
  Group By StuId

--49、检索“004”课程分数小于60，按分数降序排列的同学学号 (ok)


select 
stuid
from tblscore where courseid = '004' and score < 60
ORDER BY score DESC




/*********************************  建库建表建约束，插入测试数据  ******************************************/
Use master
go
if db_id('MySchool') is not null
 Drop Database MySchool
Create Database MySchool
go
Use MySchool
go
create table tblStudent
(
 StuId varchar(5) primary key,
 StuName nvarchar(10) not null,
 StuAge int,
 StuSex nchar(1) not null
)
create table tblTeacher
(
 TeaId varchar(3) primary key, 
 TeaName varchar(10) not null
)
create table tblCourse
(
 CourseId varchar(3) primary key,
 CourseName nvarchar(20) not null, 
 TeaId varchar(3) not null foreign key references tblTeacher(teaId)
)
create table tblScore
(
 StuId varchar(5) not null foreign key references tblStudent(stuId),
 CourseId varchar(3) not null foreign key references tblCourse(CourseId),
 Score float
)
----------------------------------表结构----------------------------------------------------
--学生表tblStudent（编号StuId、姓名Stuname、年龄Stuage、性别Stusex）
--课程表tblCourse（课程编号CourseId、课程名称CourseName、教师编号TeaId）
--成绩表tblScore（学生编号StuId、课程编号CourseId、成绩Score）
--教师表tblTeacher（教师编号TeaId、姓名TeaName）
--------------------------------插入数据-------------------------------------------------
insert into tblStudent
select '1000','张无忌',18,'男' union
select '1001','周芷若',19,'女' union
select '1002','杨过',19,'男' union
select '1003','赵敏',18,'女' union
select '1004','小龙女',17,'女' union
select '1005','张三丰',18,'男' union
select '1006','令狐冲',19,'男' union
select '1007','任盈盈',20,'女' union
select '1008','岳灵珊',19,'女' union
select '1009','韦小宝',18,'男' union
select '1010','康敏',17,'女' union
select '1011','萧峰',19,'男' union
select '1012','黄蓉',18,'女' union
select '1013','郭靖',19,'男' union
select '1014','周伯通',19,'男' union
select '1015','瑛姑',20,'女' union
select '1016','李秋水',21,'女' union
select '1017','黄药师',18,'男' union
select '1018','李莫愁',18,'女' union
select '1019','冯默风',17,'男' union
select '1020','王重阳',17,'男' union
select '1021','郭襄',18,'女' 
go

insert  into tblTeacher
select '001','姚明' union
select '002','叶平' union
select '003','叶开' union
select '004','孟星魂' union
select '005','独孤求败' union
select '006','裘千仞' union
select '007','裘千尺' union
select '008','赵志敬' union
select '009','阿紫' union
select '010','郭芙蓉' union
select '011','佟湘玉' union
select '012','白展堂' union
select '013','吕轻侯' union
select '014','李大嘴' union
select '015','花无缺' union
select '016','金不换' union
select '017','乔丹'
go

insert into tblCourse
select '001','企业管理','002' union
select '002','马克思','008' union
select '003','UML','006' union
select '004','数据库','007' union
select '005','逻辑电路','006' union
select '006','英语','003' union
select '007','电子电路','005' union
select '008','毛泽东思想概论','004' union
select '009','西方哲学史','012' union
select '010','线性代数','017' union
select '011','计算机基础','013' union
select '012','AUTO CAD制图','015' union
select '013','平面设计','011' union
select '014','Flash动漫','001' union
select '015','Java开发','009' union
select '016','C#基础','002' union
select '017','Oracl数据库原理','010'
go

insert into tblScore
select '1001','003',90 union
select '1001','002',87 union
select '1001','001',96 union
select '1001','010',85 union
select '1002','003',70 union
select '1002','002',87 union
select '1002','001',42 union
select '1002','010',65 union
select '1003','006',78 union
select '1003','003',70 union
select '1003','005',70 union
select '1003','001',32 union
select '1003','010',85 union
select '1003','011',21 union
select '1004','007',90 union
select '1004','002',87 union
select '1005','001',23 union
select '1006','015',85 union
select '1006','006',46 union
select '1006','003',59 union
select '1006','004',70 union
select '1006','001',99 union
select '1007','011',85 union
select '1007','006',84 union
select '1007','003',72 union
select '1007','002',87 union
select '1008','001',94 union
select '1008','012',85 union
select '1008','006',32 union
select '1009','003',90 union
select '1009','002',82 union
select '1009','001',96 union
select '1009','010',82 union
select '1009','008',92 union
select '1010','003',90 union
select '1010','002',87 union
select '1010','001',96 union

select '1011','009',24 union
select '1011','009',25 union

select '1012','003',30 union
select '1013','002',37 union
select '1013','001',16 union
select '1013','007',55 union
select '1013','006',42 union
select '1013','012',34 union
select '1000','004',16 union
select '1002','004',55 union
select '1004','004',42 union
select '1008','004',34 union
select '1013','016',86 union
select '1013','016',44 union
select '1000','014',75 union
select '1002','016',100 union
select '1004','001',83 union
select '1008','013',97
go

