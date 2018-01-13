/*  leave this
    l:see README
    g:parse_gold
    v:100529\s.zaglio: utility
*/
CREATE proc [dbo].[sp__parse_gold_util] @opt sysname=null
as
begin
set nocount on
declare @proc sysname,@ret int
select @proc='sp__parse_gold_util',@ret=0
if @opt is null goto help

declare @idx smallint

insert into #rule_definition
select
    r.id [index],
    case when s.type=0 then '<'+s.name+'>' else s.name end as rule_name,
    convert(nvarchar(4000),null) as definition
from #rule r
join #sym s on r.nonterminal=s.id

declare @def nvarchar(4000)
declare cs cursor local for
    select [index] from #rule_definition
open cs
while 1=1
    begin
    fetch next from cs into @idx
    if @@fetch_status!=0 break
    select @def=''

    select @def=coalesce(@def+' ','')
               +case when s.type=0 then '<'+s.name+'>' else ''''+s.name+'''' end
    from #rule_symbol rs
    join #sym s on rs.symbol_id=s.id
    where rule_id=@idx

    update #rule_definition set definition=@def where [index]=@idx
    end

close cs
deallocate cs

-- exec sp__printf '\n## rule definition table'
-- exec sp__select_astext 'select * from #rule_definition' !!! no <>
select * from #rule_definition
goto ret

help:
exec sp__usage @proc

ret:
end -- sp__parse_gold_util
