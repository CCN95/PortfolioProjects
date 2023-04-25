-- Showing the data from spotify_daily_charts table sorted from the most recent record

select *
from spotify_daily_charts
order by date desc





-- Top 10 tracks with the highest streams per day

select top 10 * 
from spotify_daily_charts
order by streams desc





-- Top 10 artists with the highest total streams

select top 10 artist, sum(streams) as totalstreams
from spotify_daily_charts
group by artist
order by totalstreams desc





-- Shows the total number of tracks or songs per artist 

select artist, count(distinct(track_name)) as numoftracks
from spotify_daily_charts
group by artist
order by numoftracks desc





-- Top 10 most followed artists

select Top 10 *
from spotify_daily_charts_artists
order by total_followers desc





-- Top 10 most followed Pinoy/OPM artists 

select top 10 *
from spotify_daily_charts_artists
where genres like '%pinoy%' or genres like '%opm%'
order by total_followers desc, popularity desc





-- Top 10 most followed pop artists 

select top 10 *
from spotify_daily_charts_artists
where genres like '%pop%'
order by total_followers desc, popularity desc





-- Top 10 most followed kpop artists 

select top 10 *
from spotify_daily_charts_artists
where genres like '%k-pop%'
order by total_followers desc, popularity desc





-- Shows the number of times a track/song ranked #1 position

select ar.artist_name, ch.track_name, count(ch.position) count_position
from spotify_daily_charts_artists ar
join spotify_daily_charts ch
	on ar.artist_name = ch.artist
where ch.position <= 1
group by ar.artist_name, ch.track_name
order by count_position desc





-- Shows the running count of a track's position who rank #1

select ch.date, ar.artist_name, ch.track_name, ar.total_followers, ch.streams, 
	count(ch.position) over (partition by ch.track_name order by ch.date) as count_position
from spotify_daily_charts_artists ar
join spotify_daily_charts ch
	on ar.artist_name = ch.artist
where ch.position <= 1





-- Number of songs by Pinoy/OPM artists which ranked #1 

With CP (date, artist, tracks, genre, followers, streams, count_position)
as
(
select ch.date, ar.artist_name, ch.track_name, ar.genres, ar.total_followers, ch.streams, 
	count(ch.position) over (partition by ch.track_name order by ch.date) as count_position
from spotify_daily_charts_artists ar
join spotify_daily_charts ch
	on ar.artist_name = ch.artist
where ch.position <= 1
)
select artist, count(distinct(tracks)) as numberofsongs
from CP
where genre like '%pinoy%' or genre like '%opm%'
group by artist





-- Number of songs by Pop artists which ranked #1 

With CP (date, artist, tracks, genre, followers, streams, count_position)
as
(
select ch.date, ar.artist_name, ch.track_name, ar.genres, ar.total_followers, ch.streams, 
	count(ch.position) over (partition by ch.track_name order by ch.date) as count_position
from spotify_daily_charts_artists ar
join spotify_daily_charts ch
	on ar.artist_name = ch.artist
where ch.position <= 1
)
select artist, count(distinct(tracks)) as numberofsongs
from CP
where genre like '%pop%' and genre not like '%k-pop%'
group by artist





-- Number of songs by K-pop artists which ranked #1 

With CP (date, artist, tracks, genre, followers, streams, count_position)
as
(
select ch.date, ar.artist_name, ch.track_name, ar.genres, ar.total_followers, ch.streams, 
	count(ch.position) over (partition by ch.track_name order by ch.date) as count_position
from spotify_daily_charts_artists ar
join spotify_daily_charts ch
	on ar.artist_name = ch.artist
where ch.position <= 1
)
select artist, count(distinct(tracks)) as numberofsongs
from CP
where genre like '%k-pop%'
group by artist





-- Correlation of Popularity to a track's release date

/* tracks which are recently released have higher popularity compare to older releases*/

select track_name, artist_name, popularity, release_date
from spotify_daily_charts_tracks
where track_name is not null
order by 3 desc,4





-- Top 10 tracks with high valence

/* Tracks with high valence sound more positive (e.g. happy, cheerful, euphoric),
while tracks with low valence sound more negative (e.g. sad, depressed, angry). */

select track_name, artist_name, popularity, valence, tempo
from spotify_daily_charts_tracks
where track_name is not null
order by valence desc





-- Creating temp table to combine selected data from the three tables

drop table if exists #ChartArtistTracks
create table #ChartArtistTracks
(
track_name nvarchar(255),
artist nvarchar(244),
position numeric,
streams numeric,
chart_date date,
duration numeric,
popularity numeric,
total_followers numeric,
danceability numeric,
energy numeric,
loudness numeric,
speechiness numeric,
acousticness numeric,
liveness numeric,
valence numeric,
tempo numeric,
release_date date,
genres nvarchar(255)
)

insert into #ChartArtistTracks
select ch.track_name, ch.artist, ch.position, ch.streams, ch.date, tr.duration, tr.popularity,
ar.total_followers, tr.danceability, tr.energy, tr.loudness, tr.speechiness, tr.acousticness,
tr.liveness, tr.valence, tr.tempo,tr.release_date, ar.genres
from spotify_daily_charts ch
join spotify_daily_charts_tracks tr
	on ch.track_id = tr.track_id
join spotify_daily_charts_artists ar
	on tr.artist_id = ar.artist_id
where ch.track_name is not null
--order by ch.track_name

select * 
from #ChartArtistTracks


/* Shows the total streams of songs that ranked #1, their popularity and genres*/

select track_name, sum(streams) as total_streams, popularity, genres
from #ChartArtistTracks
where position = 1
group by track_name, popularity, genres
order by total_streams desc