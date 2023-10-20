use ipl;

select * from ipl_player;
#1.	Show the percentage of wins of each bidder in the order of highest to lowest percentage.
select ipl_bidding_details.bidder_id,count(ipl_bidding_details.bid_status),no_of_bids,
(count(ipl_bidding_details.bid_status)/no_of_bids)*100 as percentage_win
from ipl_bidding_details
inner join ipl_bidder_points
on ipl_bidding_details.bidder_id= ipl_bidder_points.bidder_id
where ipl_bidding_details.bid_status='won'
group by ipl_bidding_details.bidder_id,no_of_bids 
order by percentage_win desc;


with temp( won, BIDDER_ID) as
(select count(NO_OF_BIDS),BIDDER_ID
from ipl_bidder_points left join ipl_bidding_details using(BIDDER_ID)
where BID_STATUS like '%won%'
group by BIDDER_ID,   BID_STATUS) 
select BIDDER_ID, ((won/NO_OF_BIDS)*100) as percentage_of_won from temp join ipl_bidder_points using(BIDDER_ID)
order by percentage_of_won desc;

#2.	Display the number of matches conducted at each stadium with the stadium name and city.
select count(ims.match_id)as no_of_matches,iss.stadium_name from ipl_stadium iss join ipl_match_schedule ims on 
iss.stadium_id =ims.stadium_id
group by iss.stadium_name;

#3.	In a given stadium, what is the percentage of wins by a team which has won the toss?
Select ist.STADIUM_NAME, 
(sum((Case
 when Toss_winner = Match_winner 
 then 1 
 else 0 
 end ))/count(*))*100 
as 'Percent Wins' 
from ipl_stadium ist join ipl_match_schedule ms 
on ist.stadium_id = ms.STADIUM_ID 
join ipl_match im on ms.match_id= im.match_id 
group by ist.STADIUM_NAME; 


#4.	Show the total bids along with the bid team and team name.
select count(bidder_id) as total_bid,bid_team,team_name
from ipl_bidding_details bd 
join ipl_team i on bid_team=i.team_id
group by bid_team;

#5.	Show the team id who won the match as per the win details.
select* from ipl_match;
select team_id, team_name, team_id1, team_id2, match_winner, ipl_match.win_details
from ipl_team
inner join ipl_match
on substr(ipl_team.remarks,1,3) = substr(ipl_match.win_details,6,3);

#6.	Display total matches played, total matches won and total matches lost by the team 
#along with its team name.

select distinct(team_id), TEAM_NAME, 
sum(MATCHES_PLAYED)over(partition by TEAM_ID) T_MATCHES_PLAYED,
sum(MATCHES_WON)over(partition by TEAM_ID) as T_MATCHES_WON,
sum(MATCHES_LOST) over(partition by TEAM_ID) as T_MATCHES_LOST
from ipl_team_standings join ipl_team using(team_id);


#7.	Display the bowlers for the Mumbai Indians team.
select* from ipl_team it join ipl_team_players itl 
on it.team_id =itl.team_id
where team_name ="Mumbai Indians" and  player_role="bowler";

#
select PLAYER_NAME, PLAYER_ID, PLAYER_ROLE, t.REMARKS as MI
from ipl_team_players t join ipl_player using(PLAYER_ID)
where t.REMARKS like '%mi%'  and PLAYER_ROLE like 'Bowler';

#8.	How many all-rounders are there in each team, Display the teams with more than 4 
#all-rounders in descending order.
select it.team_name,count(itl.player_role) as allrounder
from ipl_team it join ipl_team_players itl 
on it.team_id =itl.team_id
where itl.player_role ="All-Rounder" 
group by it.TEAM_NAME
having count(itl.player_role)>4
order by allrounder desc;

#9.	 Write a query to get the total bidders points for each bidding status of those bidders who bid on CSK when it won the match in M. Chinnaswamy Stadium bidding year-wise.
 #Note the total bidders’ points in descending order and the year is bidding year.
#Display columns: bidding status, bid date as year, total bidder’s points
with temp(b_id,tb_points) as
(select bidder_id,sum(total_points) over (partition by bidder_id)
from ipl_bidder_points)
select distinct(b_id),bid_status,year(bid_date) as bid_date,tb_points,team_name
from temp join ipl_bidding_details ibd on temp.b_id=ibd.bidder_id join ipl_match_schedule using(schedule_id)
join ipl_team it on it.team_id=ibd.bid_team
where bid_team =1 and bid_status like'%won' and stadium_id=7
order by tb_points desc;

#10.	Extract the Bowlers and All Rounders those are in the 5 highest number of wickets.
#Note 1. use the performance_dtls column from ipl_player to get the total number of wickets
#2. Do not use the limit method because it might not give appropriate results when players have the same number of wickets
#3.	Do not use joins in any cases.
#4	Display the following columns teamn_name, player_name, and player_role.

SELECT TEAM_NAME, PLAYER_NAME, PLAYER_ROLE 
FROM ipl_player inner join ipl_team_players using(PLAYER_ID) join ipl_team using(TEAM_ID)
WHERE PLAYER_ROLE IN ('Bowler', 'All-Rounder') 
ORDER BY CAST(SUBSTRING_INDEX(performance_dtls, '/', 1) AS UNSIGNED) desc limit 5;

#11.show the percentage of toss wins of each bidder and display the results in
# descending order based on the percentage

with temp(won,bidder_id) as
(select count(no_of_bids),bidder_id
from ipl_bidder_points left join ipl_bidding_details using(bidder_id)
where bid_status like '%won%'
group by bidder_id,bid_status)
select distinct(ipl_bidder_points.bidder_id), ((won/no_of_bids)*100) as percentage_of_toss_won 
from temp join ipl_bidder_points using(bidder_id)
order by percentage_of_toss_won desc;

#12.find the IPL season which has min duration and max duration.
#Output columns should be like the below:
#Tournment_ID, Tourment_name, Duration column, Duration
 use ipl;
 select tournmt_id, tournmt_name,datediff(to_date,from_date) as duration
 from ipl_tournament
 where datediff(to_date,from_date) in
 (select min(datediff(to_date,from_date)) as min_duration from ipl_tournament
 union
 (select max(datediff(to_date,from_date)) as max_duration from ipl_tournament));

#13.Write a query to display to calculate the total points month-wise for the 2017 bid year.
# sort the results based on total points in descending order and month-wise in ascending order.
#Note: Display the following columns:
#1.	Bidder ID, 2. Bidder Name, 3. bid date as Year, 4. bid date as Month, 5. Total points
#Only use joins for the above query queries.s

with temp(BIDDER_ID, BIDDER_NAME,NO_OF_BIDS, bid_date, t_points) as
(select distinct(BIDDER_ID),BIDDER_NAME, NO_OF_BIDS,  BID_DATE, total_points
from ipl_bidder_details join ipl_bidder_points using(BIDDER_ID)
join ipl_bidding_details using(bidder_id)
where BID_DATE like '%2017%')
select BIDDER_ID, BIDDER_NAME,NO_OF_BIDS, bid_date, t_points , 
sum(t_points) over (partition by (BIDDER_ID)) total_points_per_month
from temp ;
 

#14.Write a query for the above question using sub queries by having the 
#same constraints as the above question.

select bd.bidder_id, bd.bidder_name, 
year(b.bid_date) as 'year', 
month(b.bid_date) as 'month', 
(select sum(p.total_points) from ipl_bidder_points p 
where p.bidder_id = b.bidder_id and p.tournmt_id = b.schedule_id) as 'total points'
from ipl_bidding_details b
join ipl_bidder_details bd on b.bidder_id = bd.bidder_id
where year(b.bid_date) = 2017
order by (select sum(p.total_points) from ipl_bidder_points p 
where p.bidder_id = b.bidder_id and p.tournmt_id = b.schedule_id) desc, 
year(b.bid_date), 
month(b.bid_date);


#15.Write a query to get the top 3 and bottom 3 bidders based on the total bidding points for the 2018 bidding year.
#Output columns should be:
#like:
#Bidder Id, Ranks (optional), Total points, Highest_3_Bidders --> columns contains name of bidder, Lowest_3_Bidders  --> columns contains name of bidder;
with temp ( BIDDER_ID,TOTAL_POINTS,ranks)as
(select BIDDER_ID,TOTAL_POINTS,
dense_rank() over(order by TOTAL_POINTS  ) as ranks
from ipl_bidder_points
where TOURNMT_ID = 2018),

 temp2( B_ID,T_POINTS, ranks2) as
(select BIDDER_ID,TOTAL_POINTS,
dense_rank() over(order by TOTAL_POINTS asc ) as ranks2
from ipl_bidder_points
where TOURNMT_ID = 2018)

select * from temp join temp2 where ranks = 1
and ranks2 in (13,14,15);

#16.	Create two tables called Student_details and Student_details_backup.
CREATE TABLE Student_details (
    Student_id INT NOT NULL,
    Student_name VARCHAR(50) NOT NULL,
    Mail_id VARCHAR(50) NOT NULL,
    Mobile_no VARCHAR(15) NOT NULL,
    PRIMARY KEY (Student_id)
);

CREATE TABLE Student_details_backup (
    Student_id INT NOT NULL,
    Student_name VARCHAR(50) NOT NULL,
    Mail_id VARCHAR(50) NOT NULL,
    Mobile_no VARCHAR(15) NOT NULL,
    Backup_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Student_id, Backup_time)
);

CREATE TRIGGER insert_student_details
AFTER INSERT ON Student_details
FOR EACH ROW
BEGIN
    INSERT INTO Student_details_backup (Student_id, Student_name, Mail_id, Mobile_no)
    VALUES (NEW.Student_id, NEW.Student_name, NEW.Mail_id, NEW.Mobile_no)
END;



-- EXTRA Questions:

-- Question 1: Write a query to show the team with the highest number of bids.

SELECT team, COUNT(*) AS num_bids FROM bids GROUP BY team HAVING num_bids>=1 ORDER BY num_bids DESC LIMIT 1; 

#Question 2: Write a query to show the team with the lowest number of bids.

SELECT team, COUNT(*) AS num_bids FROM bids GROUP BY team HAVING num_bids>=1 ORDER BY num_bids ASC LIMIT 1; 
