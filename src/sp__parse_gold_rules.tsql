/*  leave this
    l:see README
    g:parse_gold
    v:100529\s.zaglio: well tested; chg grp
    r:100501\s.zaglio: populate tables for gold parser
    t:sp__parse_gold_rules @dbg=1
*/
CREATE proc [dbo].[sp__parse_gold_rules]
    @case_sensitive bit     =null out,
    @start_symbol smallint  =null out,
    @init_dfa smallint      =null out,
    @init_lalr smallint     =null out,
    @dbg bit                =0
as
begin
set nocount on
declare @proc sysname,@ret int
select @proc='sp__parse_gold_rules',@ret=0
-- test #cgt

/*
drop proc #ex
create proc #ex @i int,@n int=256
as
set nocount on
declare @t table(id int, v int,c char, dc char, b varbinary, nc nchar,cc smallint,uc smallint)
select @n=@n+@i
while @i<=@n begin
    insert @t
    select @i,convert(tinyint,substring(blob,@i,1)),convert(char,substring(blob,@i,1)),substring(blob,@i,1),
           substring(blob,@i,1),substring(blob,@i,1),convert(smallint,substring(blob,@i,2)),
           unicode(substring(blob,@i,2))
           from #cgt
    select @i=@i+1
    end
select * from @t order by id
*/

/*
create table #cgt(blob image)
exec sp__parse_gold_cgt

create table #struct(
    tid     tinyint,
    id      smallint identity(0,1),
    rid     smallint null,
    pid1    smallint null,
    pid2    smallint null,
    pid3    smallint null,
    pid4    smallint null,
    pid5    smallint null,
    flags   smallint null,
    n       smallint null,
    dat     nvarchar(4000) null
    )

exec sp__drop '#rule_definition'
create table #rule_definition(
    [index]     smallint,
    [name]      sysname,
    definition  nvarchar(4000)
    )

-- mapping #sym,#charset,... to #struct
--  struct.fld  #sym    #charset    #rule_symbol    #rule           #dfa_sate
    tid         1       2           3               4               5
    pid1                id          rule_id         nonterminal     id
    pid2        type    charset     symbol_id                       acceptindex
    pid3
    pid4
    pid5
    flags                                                           accept
    dat         name
    n                                               nsymbol         nedge

--  struct.fld  #edge           #lalr_action
    tid         6               7
    pid1        dfa_id          lalr_id
    pid2        edge_id         idx
    pid3        charsetindex    symbolindex
    pid4        targetindex     action
    pid5                        target
    flags
    dat
    n

truncate table #sym
truncate table #charset
truncate table #rule_symbol
truncate table #rule
truncate table #dfa_state
truncate table #edge
truncate table #lalr_action
*/

truncate table #struct
-- if @extra=1 truncate table #rule_definition

declare @t_sym          tinyint select @t_sym=1
declare @t_charset      tinyint select @t_charset=2
declare @t_rule_symbol  tinyint select @t_rule_symbol=3
declare @t_rule         tinyint select @t_rule=4
declare @t_dfa_state    tinyint select @t_dfa_state=5
declare @t_edge         tinyint select @t_edge=6
declare @t_lalr_action  tinyint select @t_lalr_action=7


-- drop proc #malloc
exec('
create proc #malloc @tid tinyint,@size int
as
declare @sql nvarchar(512)
insert #struct(tid,rid)
select @tid,row from dbo.fn__range(0,@size-1,default)
exec(@sql)
')
/*
exec('
create proc #malloc @array sysname,@size int
as
declare @sql nvarchar(512)
select @sql=''insert ''+@array+''(id) select row from dbo.fn__range(0,''+convert(sysname,@size-1)+'',1)''
exec(@sql)
')*/
-- #malloc '#sym',100

-- drop proc #getvws
exec('
create proc #getvws @b int,@str nvarchar(4000) out
as
select @b=@b+1
declare @c nchar
select @str='''',@c=substring(blob,@b,2) from #cgt
while (unicode(@c)!=0x0000)
    begin
    select @str=@str+@c,@b=@b+2
    select @c=substring(blob,@b,2) from #cgt
    -- print unicode(@c)
    end
select @b=@b+2  -- skip (nchar) \0
return @b
')
-- drop proc #skipvws
exec('
create proc #skipvws @b int,@n int=1
as
declare @c nchar
while @n>0
    begin
    select @b=@b+1,@c=substring(blob,@b,2) from #cgt
    while (unicode(@c)!=0x0000)
        select @b=@b+2,@c=substring(blob,@b,2) from #cgt
    select @b=@b+2,@n=@n-1  -- skip (nchar) \0
    end
return @b
')
-- drop proc #getvsh
exec('
create proc #getvsh @b int,@v smallint out
as
declare @i int
select @b=@b+1,@i=unicode(substring(blob,@b,2)),@b=@b+2 from #cgt
if @i<32768 select @v=@i else select @v=~(65535-@i)
return @b
')


declare
    @b int,@bend int,@nEntries smallint,@recType char,
    @c char,@vsh smallint,@idx smallint,@i smallint,
    @n smallint,@byt tinyint,@vsh1 smallint

select @b=0,@bend=datalength(blob) from #cgt
declare @str nvarchar(4000)

exec @b=#getvws @b,@str out  -- remember that @b start from 0
if @str!=N'GOLD Parser Tables/v1.0' goto err_ver

-- print @b -- 49
while ( @b <= @bend )
    begin
    -- skip record id M(0x4D)
    exec @b=#getvsh @b,@nEntries out
    -- getvb
    select @b=@b+1,@recType =substring(blob,@b,1),@b=@b+1 from #cgt
    if @dbg=1 exec sp__printf 'rectype:%s; b:%d, bend:%d',@rectype,@b,@bend
    if @recType='P' -- parameters
        begin
        exec @b=#skipvws @b,4   -- name,version,author,about
        -- #ex 220
        select @b=@b+1,@byt=substring(blob,@b,1),@b=@b+1 from #cgt
        select @case_sensitive=@byt
        -- getvsh
        exec @b=#getvsh @b,@start_symbol out
        -- update #parse_config set case_sensitive=@byt,start_symbol=@start_symbol
        -- #ex 223
        continue
        end -- rc:P

    if @recType='T' -- table counts
        begin
        exec @b=#getvsh @b,@vsh out     -- nsym
        exec #malloc @t_sym,@vsh
        exec @b=#getvsh @b,@vsh out     -- ncharset
        exec #malloc @t_charset,@vsh
        exec @b=#getvsh @b,@vsh out     -- nrule
        exec #malloc @t_rule,@vsh
        exec @b=#getvsh @b,@vsh out     -- ndfa_state
        exec #malloc @t_dfa_state,@vsh
        -- integrate in lalr_action
        exec @b=#getvsh @b,@vsh out     -- nlalr_state
        -- exec #malloc '#lalr_state',@vsh
        continue
        end -- rc:T

    if @recType='I' -- initial states
        begin
        exec @b=#getvsh @b,@init_dfa out     -- init_dfa
        exec @b=#getvsh @b,@init_lalr out    -- init_lalr
        -- update #parse_config set init_dfa=@init_dfa,init_lalr=@init_lalr
        continue
        end -- rc:I

    if @recType='S' -- symbol entry
        begin
        exec @b=#getvsh @b,@idx out     -- idx
        exec @b=#getvws @b,@str out     -- str
        exec @b=#getvsh @b,@vsh out     -- sym type
        -- update #sym set [type]=@vsh,[name]=@str where id=@idx
        update #struct set pid2=@vsh,dat=@str where tid=@t_sym and rid=@idx
        -- maybe can be replaced & optimized with insert
        continue
        end -- rc:s

    if @recType='C' -- character set entry
        begin
        exec @b=#getvsh @b,@idx out     -- idx
        exec @b=#getvws @b,@str out     -- str
        if len(@str)>128 exec sp__err 'charset greater than 128 chars'
        -- update #charset set charset=@str where id=@idx
        update #struct set dat=@str where tid=@t_charset and rid=@idx
        continue
        end -- rc:c

    if @recType='R' -- rule table entry
        begin
        exec @b=#getvsh @b,@idx out     -- idx
        exec @b=#getvsh @b,@vsh out     -- NonTerminal
        select @b=@b+1  -- reserver
        select @n=@nEntries-4
        -- update #rule set NonTerminal=@vsh,nsymbol=@n where id=@idx
        update #struct set pid1=@vsh,n=@n where tid=@t_rule and rid=@idx
        while (@n>0)
            begin
            exec @b=#getvsh @b,@vsh out -- rule-symbol
            -- insert #rule_symbol(rule_id,symbol_id)
            insert #struct(tid,pid1,pid2)
            select @t_rule_symbol,@idx,@vsh
            select @n=@n-1
            end -- rule symbols
        continue
        end -- rc:R

    if @recType='D' -- dfa state entry
        begin
        exec @b=#getvsh @b,@idx out
        select @b=@b+1,@byt=substring(blob,@b,1),@b=@b+1 from #cgt
        exec @b=#getvsh @b,@vsh out     -- AcceptIndex  (can be -1)
        select @n=@nEntries-5
        /* update #dfa_state set
            AcceptIndex=@vsh,
            Accept=@byt,
            nedge=@n/3
           where id=@idx*/

        update #struct set
            pid2 = @vsh,
            flags = @byt,
            n = @n/3
        where tid=@t_dfa_state
        and rid=@idx

        select @b=@b+1  -- reserved
        -- #dfa_state[idx].nedge=(@nEntries-5)/3
        -- malloc dfa_state[idx].edge
        while (@n>0)
            begin
            exec @b=#getvsh @b,@vsh  out -- edge.CharSetIndex
            exec @b=#getvsh @b,@vsh1 out -- edge.TargetIndex
            -- insert #edge(dfa_id,edge_id,CharSetIndex,TargetIndex)
            insert #struct(tid,pid1,pid2,pid3,pid4)
            select
                @t_edge,
                @idx,
                -- coalesce((select max(edge_id) from #edge where dfa_id=@idx)+1,0),
                coalesce((select max(pid2)      -- edge_id
                          from #struct
                          where tid=@t_edge
                          and pid1=@idx)+1,0),  -- dfa_id
                @vsh,@vsh1
            select @b=@b+1  -- reserved
            select @n=@n-3
            end -- edge loop
        continue
        end -- rc:D

    if @recType='L' -- lalr state entry
        begin
        exec @b=#getvsh @b,@idx out
        select @b=@b+1  -- reserved
        select @n=(@nEntries-3)
        --#malloc '#lalr_action',@n
        while (@n>0)
            begin
            exec @b=#getvsh @b,@i    out -- SymbolIndex
            exec @b=#getvsh @b,@vsh  out -- Action
            exec @b=#getvsh @b,@vsh1 out -- Target
            -- insert #lalr_action(lalr_id,idx,SymbolIndex,[Action],Target)
            insert #struct(tid,    pid1,   pid2,pid3,      pid4,    pid5)
            select @t_lalr_action,@idx,coalesce((select max(pid2) -- idx
                                                 from #struct
                                                 where tid=@t_lalr_action
                                                 and pid1=@idx)+1,0), -- lalr_id
            -- select @t_lalr_action,@idx,coalesce((select max(idx) from #lalr_action where lalr_id=@idx)+1,0),
                   @i,@vsh,@vsh1
            select @b=@b+1  -- reserved
            select @n=@n-4
            end -- actions loop
        continue
        end -- rc:L

        -- #ex 6363
    exec @ret=sp__err 'unknow or not managed record'
    break

    end -- cgt scan

drop proc #getvws
drop proc #skipvws
drop proc #getvsh
drop proc #malloc

if @dbg=1
    begin
    exec sp__select_astext 'select * from #struct order by 1'
    /*
    exec sp__printf '\n## symbol table'
    exec sp__select_astext 'select * from #sym'
    exec sp__printf '\n## charset table'
    exec sp__select_astext 'select * from #charset'
    exec sp__printf '\n## rule-symbol table'
    exec sp__select_astext 'select * from #rule_symbol'
    exec sp__printf '\n## rule table'
    exec sp__select_astext 'select * from #rule'
    exec sp__printf '\n## dfa table'
    exec sp__select_astext 'select * from #dfa_state'
    exec sp__printf '\n## edge table'
    exec sp__select_astext 'select * from #edge'
    exec sp__printf '\n## action table'
    exec sp__select_astext 'select * from #lalr_action'
    */
    end

goto ret

err_ver:    exec @ret=sp__err 'unknown table version "%s"',@proc,@p1=@str

ret:
return @ret
end -- sp__parse_golden_rules
