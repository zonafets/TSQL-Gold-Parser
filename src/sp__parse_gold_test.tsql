/*  leave this
    l:see README
    g:parse_gold
    v:100529\s.zaglio: test parser
*/
CREATE proc sp__parse_gold_test
as
begin
set nocount on
create table #src(lno int identity,line nvarchar(4000))
/*
insert #src select 'DISPLAY ''Enter a number'' READ Num'+char(13)+char(10)
insert #src select 'ASSIGN Num = Num * 2'+char(13)+char(10)
insert #src select 'DISPLAY ''This the square of the number'' & Num'+char(13)+char(10)
*/
insert #src select 'a + b * c'  -- error on 'a' expected if assign ...
create table #cgt(blob image)
exec sp__parse_gold_cgt_test

exec sp__parse_gold_dbg
drop table #src
drop table #cgt
end -- sp__parse_gold_test
