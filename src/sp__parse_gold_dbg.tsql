/*  leave this
    l:see README
    g:parse_gold
    r:111224\s.zaglio: restyle
    r:100529\s.zaglio: debug form of parser
*/
CREATE proc [dbo].[sp__parse_gold_dbg]
    @opt sysname=null,
    @out sysname=null,
    @dbg bit=0
as
begin
set nocount on
declare @proc sysname,@ret int
select @proc=object_name(@@procid),@ret=0

if object_id('tempdb..#src') is null goto help

-- test
-- drop table #src
-- drop table #cgt
/*
create table #src(lno int identity,line nvarchar(4000))
truncate table #src
-- insert #src select 'assign a=a+b*c'
insert #src -- select * from #src
select line
from fn__ntext_to_lines('
DISPLAY ''Enter a number'' READ Num
ASSIGN Num = Num * 2
DISPLAY ''This the square of the number'' & Num
',0)
create table #cgt(blob image)
exec sp__parse_gold_cgt_test
*/
-- select * from #src

-- load cgt (compiled grammar template)

-- declare @dbg bit select @dbg=0
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

-- load rules table from #cgt
-- parser->pconfig
declare
    @case_sensitive bit,
    @start_symbol smallint,
    @init_dfa smallint,
    @init_lalr smallint


-- ============================
-- =  load and expand rules   =
-- ============================
exec sp__parse_gold_rules
    @case_sensitive out,
    @start_symbol   out,
    @init_dfa       out,
    @init_lalr      out,
    @dbg=0

-- drop table #local
create table #local(
    dbg         bit null,
    -- parser
    reduction   bit null,           -- char reduction;
    reduce_rule smallint null,      -- short reduce_rule;
    lexeme      nvarchar(512) null, -- char* lexeme;
    nlexeme     smallint null,      -- int nlexeme;
    lalr_state  smallint null,      -- short lalr_state;
    --                              -- void* symbol_userdata;
    -- #stack_element               -- struct _stack_element*    stack;
    -- max(id)                      -- short nstack;
    -- autoincremental              -- short nstacksize;
    nstackofs   int null,           -- size_t nstackofs;

    -- indexes
    nactions            int null,
    nstack              int null,
    ntokens             int null,
    symbol_userdata     nvarchar(4000) null,

    -- struct _parse_config* pconfig;
    case_sensitive      bit null,
    start_symbol        smallint null,
    init_dfa            smallint null,
    init_lalr           smallint null,

    -- #cbmatchtoken                -- _cbmatchtoken cbmatchtoken;
    --                              -- void* user_callback;

    -- struct _parse_input input;
    row             int null,               -- current row
    lrow            int null,               -- last row
    nofs            smallint null,
    ncount          smallint null,          -- last col
    buffer          nvarchar(4000) null,    -- curren line buffer
    -- #src(lno int,line nvarchar(4000))

    -- tokens                      -- struct _token* tokens;
    -- count(*)                     -- short ntokens;

    -- Reduction Tree
    -- #stack_element (idx)         -- struct _stack_element* rt;
    --                              -- short rtsize;
    rtofs           int null,       -- int rtofs;


    -- locals

    id int null,
    stack_id int null,

    symbol smallint null,
    sym_name nvarchar(4000) null,
    sym_type smallint null,

    rule_id             smallint null,
    rule_nsymbol        smallint null,
    rule_nonterminal    smallint null,

    i int,n int,

    bfound       bit null,
    a_action     smallint null,
    a_lalr_id    smallint null,
    a_target     smallint null,
    a_SymbolIndex smallint null,

    -- scanner_scan
    dfa_id      smallint null,
    dfa_accept  bit null,
    dfa_acceptindex smallint null,

    charset     sysname null,

    ss_lexeme   nvarchar(4000) null,
    start_ofs   int null,
    last_accepted       int null,
    last_accepted_size  int null,
    invalid     tinyint null,

    bpreserve   bit null,
    nedge       smallint null,
    c           nchar null,
    idx         smallint null,
    TargetIndex smallint null,
    strchr      smallint null,
    m           smallint null,

    parse       int null,
    parse_ret   as parse,   -- test synon
    [like]      as N'%',
    [empty_str] as N'',
    token_row   smallint null,
    token_col   smallint null
)
-- insert #local (reduction) select null

exec sp__drop '#sym'
create table #sym(
    id      smallint    primary key,
    [Name]  sysname     null,
    [Type]  smallint    null
    )

exec sp__drop '#charset'
create table #charset(
    id          smallint    primary key,
    charset     sysname     null
    )

exec sp__drop '#rule_symbol'
create table #rule_symbol(
    id          smallint identity(0,1),
    rule_id     smallint,
    symbol_id   smallint
    )

exec sp__drop '#rule'
create table #rule(
    id          smallint primary key,
    NonTerminal smallint null,
    nsymbol     smallint null
    )

exec sp__drop '#dfa_state'
create table #dfa_state(
    id          smallint    primary key,
    Accept      bit         null,
    AcceptIndex smallint    null,
    nedge       smallint    null,
    )

exec sp__drop '#edge'
create table #edge(
    id              smallint    identity(0,1),
    dfa_id          smallint    null,
    edge_id         smallint    null,
    CharSetIndex    smallint    null,
    TargetIndex     smallint    null
    )

exec sp__drop '#lalr_action'
create table #lalr_action(
    lalr_id     smallint    null,   -- parent
    idx         smallint    null,   -- [idx]
    SymbolIndex smallint    null,
    [Action]    smallint    null,
    Target      smallint
    )

/*
-- mapping #sym,#charset,... to #struct
--  struct.fld  #sym    #charset    #rule_symbol    #rule           #dfa_state
    tid         1       2           3               4               5
    rid         id      id                                          id
    pid1                            rule_id         nonterminal
    pid2        type    charset     symbol_id                       acceptindex
    pid3
    pid4
    pid5
    flags                                                           accept
    dat         name
    n                                               nsymbol         nedge

--  struct.fld  #edge           #lalr_action
    tid         6               7
    rid
    pid1        dfa_id          lalr_id
    pid2        edge_id         idx
    pid3        charsetindex    symbolindex
    pid4        targetindex     action
    pid5                        target
    flags
    dat
    n
*/
-- load rules in memory tables
declare @t_sym          tinyint select @t_sym=1
declare @t_charset      tinyint select @t_charset=2
declare @t_rule_symbol  tinyint select @t_rule_symbol=3
declare @t_rule         tinyint select @t_rule=4
declare @t_dfa_state    tinyint select @t_dfa_state=5
declare @t_edge         tinyint select @t_edge=6
declare @t_lalr_action  tinyint select @t_lalr_action=7

truncate table #sym truncate table #charset truncate table #rule_symbol
truncate table #rule truncate table #dfa_state truncate table #edge
truncate table #lalr_action

insert #sym(id,[name],[type])
select rid,dat,pid2 from #struct where tid=@t_sym

insert #charset(id,charset)
select rid,dat from #struct where tid=@t_charset

insert #rule_symbol(rule_id,symbol_id)
select pid1,pid2 from #struct where tid=@t_rule_symbol

insert #rule(id,nonterminal,nsymbol)
select rid,pid1,n from #struct where tid=@t_rule

insert #dfa_state(id,acceptindex,accept,nedge)
select rid,pid2,flags,n from #struct where tid=@t_dfa_state

insert #edge(dfa_id,edge_id,charsetindex,targetindex)
select pid1,pid2,pid3,pid4 from #struct where tid=@t_edge

insert #lalr_action(lalr_id,idx,symbolindex,[action],target)
select pid1,pid2,pid3,pid4,pid5 from #struct where tid=@t_lalr_action

-- extra description table
exec sp__drop '#rule_definition'
create table #rule_definition(
    [index]     smallint,
    [name]      sysname,
    definition  nvarchar(4000)
    )
exec sp__parse_gold_util 'rules'


exec sp__drop '#token'
create table #token(
    id          smallint        primary key,
    symbol      smallint        null,
    lexeme      nvarchar(512)   null,
    row         smallint        null,
    col         smallint        null
    )

/* parser->stack,parser->rt
    are unified under same table;
    record are separate by use field,
    and they are managed with a reference counter
*/
exec sp__drop '#element'
create table #element(
    id          int         primary key,
    symbol/*id*/smallint    null,   -- struct _symbol    symbol;
    token /*id*/smallint    null,   -- struct _token    token;
    row         smallint    null,
    col         smallint    null,
    lexeme      nvarchar(4000) null,-- where symbol is null, is nonterminal
    [state]     smallint    null,   -- short state;
    [rule]      smallint    null,   -- short rule;
    -- void*        user_data;
    -- reduction tree
    -- #rtidx                       -- short* rtchildren;   --> #stack_rtchildren.stack_id
    -- nrtchild    smallint    null,
    nrtchild    smallint    null
    -- end reduction tree
    )


-- parser->stack->rtchildren, parser->rt, rtIdx
exec sp__drop '#rtIdx'
create table #rtIdx(
    rid         int,                            -- #stack.id or -#rt.id
    idx         int,
    val         smallint    null                -- value
    )

select top 0 * into #stack  from #element       -- parser->stack
select top 0 * into #rt     from #element       -- parser->rt
select top 0 * into #stack_child from #rtIdx
select top 0 * into #rt_child    from #rtIdx

-- ============================
-- =         main             =
-- ============================

-- struct parse_parser,parse_config

-- !!! actually the structure are autoexpanding
-- parser_create
truncate table #local
insert #local ( dbg,
                reduction,  reduce_rule,    lexeme, nlexeme,    symbol,
                lalr_state, nstackofs,  nstack,     ntokens,    rtofs,
                case_sensitive,   start_symbol, init_dfa, init_lalr,
                row,    lrow,
                nofs,   ncount
                )
select          @dbg,
                0,          0,              '',     0,          0,
                0,          0,          0,          0,          1,
                @case_sensitive,    @start_symbol,  @init_dfa,  @init_lalr,
                (select min(lno) from #src),    (select max(lno) from #src),
                0,      0


declare
    @run bit,@p int,
    @lno int,@line nvarchar(4000),

    /*  disabled and inserted into #local
    -- struct _symbol
    @sym_id smallint,
    @sym_name nvarchar(4000),
    @sym_type smallint,

    -- struct _rule
    @rule_id smallint,          -- parser->pconfig->rule[parser->reduce_rule]
    @rule_nsymbol smallint,
    @rule_nonterminal smallint,

    @n int,@i int,@id int,      -- comodity
    @stack_id int,
    */

    @end_declare bit

/*
set nocount on
close src open src
-- insert #local(id) select null
update #local set row=(select min(lno) from #src),
                  lrow=(select max(lno) from #src),
                  nofs=0,dfa_id=0,strchr=0,init_dfa=0,
                  ncount=0, lexeme=null,c=null

exec #scanner_get_char
declare @c nchar(1)
select @c=c from #local
update #local set nofs=nofs+1
while not @c is null
    begin
    exec sp__select_astext 'select c,nofs,row,lrow,ncount from #local',@header=0
    exec #scanner_get_char
    select @c=c from #local
    update #local set nofs=nofs+1
    end
*/

-- update #local set nofs=0,ncount=0,buffer=null,row=1,lrow=3; close src; open src
-- select * from #src
-- drop proc #scanner_get_char
exec('
-- get next char from buffer of source file and load next chunk of file
-- a chunk is a line
create proc #scanner_get_char
    @nofs   smallint = null out,
    @ncount smallint = null out,
    @row    int      = null out,
    @lrow   int      = null out,
    @c      nchar    = null out,
    @buffer nvarchar(4000) = null out,
    @case_sensitive bit    = null
as
select top 1
    @nofs=nofs,@ncount=ncount,@row=row,@lrow=lrow,@c=c,
    @buffer=buffer,@case_sensitive=case_sensitive
from #local

if (@nofs>@ncount or (@nofs=0 and @ncount=0))
and @row<=@lrow
    begin
    declare @line nvarchar(4000),@lno int
    fetch next from src into @lno,@line
    if @@fetch_status!=0
        begin
        select @c = null,@row=@lrow+1
        -- exec sp__printf ''EOF''
        end
    else
        begin
        -- exec sp__printf ''fetch line %s'',@line
        select
            @nofs=1,
            @row=@lno,
            @ncount=len(@line),
            @buffer=@line,
            @c = case
                 when @case_sensitive=0
                 then lower(substring(@line,1,1))
                 else substring(@line,1,1)
                 end -- case
        end
    end
else
    begin
    select
        @c = case
             when @row>@lrow then null
             when @case_sensitive=0 then lower(substring(@buffer,@nofs,1))
             else substring(@buffer,@nofs,1)
             end -- case
    -- exec sp__printf ''get ch:%s as pos %d'',@c,@nofs
    end

update top (1) #local set
    nofs=@nofs,ncount=@ncount,row=@row,lrow=@lrow,c=@c,buffer=@buffer

')

-- ------------------------------------------------ match_token
exec('
create proc #match_token
    @last_accepted int=null out,
    @nofs smallint = null out,
    @m smallint = null out,
    @c nchar = null out,
    @symbol smallint=null out
as
-- accept, ignore or invalid token
-- _cbnatchtoken....
-- parser->lexeme[last_accepted_size]=0

-- if ( !m(parser, parser->user_callback, p ...

--    Default scanner match function
--    //
--    // Symbol Types
--    //
declare
    @SymbolTypeNonterminal        tinyint,
    @SymbolTypeTerminal            tinyint,
    @SymbolTypeWhitespace        tinyint,
    @SymbolTypeEnd              tinyint,
    @SymbolTypeCommentStart        tinyint,
    @SymbolTypeCommentEnd        tinyint,
    @SymbolTypeCommentLine        tinyint,
    @SymbolTypeError            tinyint

select
    @SymbolTypeNonterminal        =0,
    @SymbolTypeTerminal            =1,
    @SymbolTypeWhitespace        =2,
    @SymbolTypeEnd              =3,
    @SymbolTypeCommentStart        =4,
    @SymbolTypeCommentEnd        =5,
    @SymbolTypeCommentLine        =6,
    @SymbolTypeError            =7

-- char scanner_def_matchtoken(struct _parser* parser, void* user, short type, char* name, short symbol)
declare
    @sym_type smallint,
    @sym_name nvarchar(4000)

select top 1
    @last_accepted=/*dfa_*/last_accepted,
    @symbol=last_accepted,
    @m=m,
    @c=c,
    @nofs=nofs
from #local

select top 1
    @sym_type=sym.type,
    @sym_name=sym.name
from #sym sym
where sym.id=@last_accepted

-- switch (type)
if @sym_type = @SymbolTypeCommentLine
    begin
    -- (scanner_get_char(peraser)
    while (1=1)
        begin
        exec #scanner_get_char @c=@c out,@nofs=@nofs out
        if @c is null break     -- if EEOF break while
        if @c = nchar(13)
            begin
            select @nofs=@nofs+1                    -- scanner_next_char
            exec #scanner_get_char @c=@c out,@nofs=@nofs out
            if @c = nchar(10)
                begin
                select @m=0,@nofs=@nofs+1           -- scanner_next_char
                goto end_match
                end -- if c==10
            select @m=0
            goto end_match
            end --if c==13
        select @nofs=@nofs+1               -- scanner_next_char
        end  -- while
    select @m=0
    goto end_match
    end -- SymbolTypeCommentLine

if @sym_type = @SymbolTypeWhitespace
    begin
    select @m=0
    goto end_match
    end -- SymbolTypeWhitepace

-- default:
select @m=1

end_match:
update #local set m=@m,c=@c,nofs=@nofs,symbol=@symbol
')
-- drop proc #reset
exec('
create proc #reset
as
-- reset char read
close src open src
-- insert #local(id) select null
update #local set row=(select min(lno) from #src),
                  lrow=(select max(lno) from #src),
                  nofs=0,dfa_id=0,strchr=0,init_dfa=0,
                  ncount=0, lexeme=null,c=null,
                  nstack=0, rtofs=1,reduction=0,nstackofs=0,ntokens=0,
                  lalr_state=init_lalr,reduce_rule=0,
                  parse=null,symbol=null,sym_name=null
truncate table #stack
truncate table #rt
insert #rt(id,symbol,token,lexeme,[state],[rule],nrtchild)
select 0,0,0,null,0,0,0
truncate table #token
truncate table #stack_child
truncate table #rt_child
truncate table #rtIdx
')
-- ------------------------------------------------ scanner_scan
-- drop proc #scanner_scan
exec('
create proc #scanner_scan
    @nofs smallint = null out,
    @last_accepted int = null out

as -- return symbol=last_accepted or 0 for eof or -1 for invalid
/*
    Scan input for next token --------------------------------------
*/
declare
    @m smallint,
    @c nchar

update #local set
    invalid=0,lexeme=null,last_accepted=-1,last_accepted_size=0,
    dfa_id=#dfa_state.id,dfa_accept=#dfa_state.accept,
    dfa_acceptindex=#dfa_state.acceptindex,
    nedge=#dfa_state.nedge,
    strchr=0,
    bpreserve=0,    -- parser->input.bpreserver
    symbol=0        -- returned value from scanner_scan if eof
    -- start_ofs=pinput->nofs
from #dfa_state
where #dfa_state.id=#local.init_dfa

-- check for eof  (scanner_get_eof(parser))
-- 1st check try to read next chunk of buffer
exec #scanner_get_char @c=@c out,@nofs=@nofs out --- as ex eof

-- begin of scanner_scan --------------------------------------------
while 1=(select case when not (select coalesce(@c,lexeme) from #local) is null then 1 else 0 end ) -- while scanner_scan
    begin

    update #local set
        dfa_id=edge.TargetIndex,
        dfa_accept=dfa.accept,
        last_accepted=case dfa.accept when 1 then dfa.AcceptIndex else -1 end,
        strchr=1,
        lexeme=coalesce(lexeme,empty_str)+@c
    -- select dfa.*,edge.*,cs.*  -- select * from #dfa_state
    from #local
    join #edge edge on edge.dfa_id=#local.dfa_id
    -- select * from #edge where dfa_id=0
    join #charset cs on edge.charsetindex=cs.id
                     and cs.charset like #local.[like]+#local.c+#local.[like]
                         collate Latin1_General_BIN
    left join #dfa_state dfa on dfa.id=edge.TargetIndex
    update #local set nedge=@@rowcount

    -- if ((c==EEOF) || (i==nedge))
    if @c is null
    or (select nedge from #local)=0
        begin

        exec #match_token @m=@m out,@last_accepted=@last_accepted out,@nofs=@nofs out

        if @m=0
            begin
            -- ignore reset state
            update #local set lexeme=null
            if @c is null
            or (select last_accepted from #local)=-1
                begin
                update #local set last_accepted=0
                break -- return 0
                end

            update #local set
                dfa_id=#dfa_state.id,dfa_accept=#dfa_state.accept,
                dfa_acceptindex=#dfa_state.acceptindex,
                nedge=#dfa_state.nedge,
                last_accepted = -1,
                start_ofs = nofs
            from #local,#dfa_state
            where #dfa_state.id=#local.init_dfa

            goto scanner_scan_getch
            end -- if ( !m(parser, parser-

        break -- exit from scanner_scan
        end -- if ((c==EEOF) || (i==nedge))

    -- move to next character
    update #local set @nofs=nofs=nofs+1

    scanner_scan_getch:
    -- (scanner_get_char(peraser)
    exec #scanner_get_char @c=@c out,@nofs=@nofs out --- as ex eof

    end -- while of scanner_scan

-- end of scanner_scan --------------------------------------------


if (select last_accepted from #local)=-1
    begin
    update #local set lexeme=null
    goto exit_scan
    end

-- push_token parser->symbol,parser->lexeme
update #local set symbol=last_accepted              -- !!! not necessary
if (select symbol from #local)>0
    begin
    insert #token(id,symbol,lexeme,row,col)
    select ntokens,symbol,lexeme,token_row,token_col
    from #local
    update #local set
        ntokens=ntokens+1,
        token_row=row,
        token_col=nofs-len(lexeme)
    end

exit_scan:
')
-- ------------------------------------------------ parse
-- drop proc #parse  -- #reset  -- #reduction
exec('
create proc #parse
as -- return
while (1=1) -- there are tokens to parse/reduce
    begin
    if (select ntokens from #local)=0
        begin -- no input tokens on stack, grab one from the input stream
        exec #scanner_scan
        end -- no #token -- #sym

    -- retrive the last token from the input stack
    if (select ntokens from #local)>0
        update #local set symbol=token.symbol,lexeme=token.lexeme,i=0
        from #token token
        where token.id=#local.ntokens-1
    else
        update #local set i=0

    -- search symbol -- set nocount off
    update #local set
        a_action=la.[action],
        a_SymbolIndex=la.SymbolIndex,
        a_target=la.target,
        i=1
    from #lalr_action la,#local
    where la.lalr_id=#local.lalr_state
    and la.SymbolIndex=#local.symbol

    if @@rowcount = 1
        begin
        /*
        #define ActionShift        1
        #define ActionReduce    2
        #define ActionGoto        3
        #define ActionAccept    4
        */
        if (select a_action from #local)=1    -- ActionShift
            begin
            -- push a symbol onto the stack
            /*
            update #local set                                   -- !!! already contain the symbols info
                sym_name=#sym.[name],sym_type=#sym.[type]
            from #sym
            where #sym.id=#local.symbol
            */

            insert #stack(
                id,symbol,token,lexeme,
                [state],[rule],nrtchild,
                row,col
                )
            select
                #local.nstack,#local.symbol,#local.symbol,#local.lexeme,
                #local.lalr_state,#local.reduce_rule,0,
                #local.token_row,#local.token_col
            from #local

            update #local set
                nstackofs = nstack,
                nstack = nstack +1,
                lalr_state = a_target

            -- pop_token from stack
            update #local set ntokens=ntokens-1
            delete #token from #token,#local where #token.id=#local.ntokens

            continue -- skip test of bfound but continue reduction
            end -- actionshift

        if (select a_action from #local)=2    -- ActionReduce
            begin
            --
            -- Reducing a rule is done in two steps:
            -- 1] Setup the stack offset so the calling function
            --    can reference the rule''s child lexeme values when
            --    this action returns
            -- 2] When this function is called again, we will
            --    remove the child lexemes from the stack, and replace
            --    them with an element representing this reduction
            --
            update #local set
                lexeme = null,
                symbol_userdata = null,
                reduce_rule = #local.a_target,
                reduction = 1,
                rule_id = r.id,
                rule_nonterminal = r.nonterminal,
                parse = r.nonterminal,
                rule_nsymbol = r.nsymbol,
                nstackofs = nstack - r.nsymbol
            from #rule r,#local
            where r.id=#local.a_target

            goto ret_parse
            end -- ActionReduce

        if (select a_action from #local)=3    -- ActionGoto
            begin
            update #local set lalr_state=a_target,ntokens=ntokens-1 from #local
            delete #token from #token,#local where #token.id=#local.ntokens
            continue -- skip test of bfound but continue reduction
            end -- ActionGoto

        if (select a_action from #local)=4    -- ActionAccept
            begin
            -- Eof, the main rule has been accepted
            update #local set parse=0
            goto ret_parse
            end -- ActionAccept

        end -- if bfound

    else    -- @@rowcount=0

        begin
        if (select symbol from #local)>0 break; -- #sym
        update #local set parse=0 -- eof
        goto ret_parse -- break;
        end

    end -- while (1) -- parse tokens or there are token to parse/reduce

update #local set parse=-1  -- token not found in rule

ret_parse:
')

-- ------------------------------------------------ reduction
exec('create proc #reduction as
    if (select reduction from #local)!=0
        begin

        update #local set                               -- !!! already loaded
            rule_id=[rule].id,
            rule_nonterminal=[rule].nonterminal,
            rule_nsymbol=[rule].nsymbol,
            symbol=[rule].nonterminal
        from #rule [rule],#local
        where [rule].id=#local.reduce_rule

        update #local set i=0

        -- push_token parser->symbol,0
        insert #token(id,symbol,lexeme)
        select ntokens,symbol,null from #local
        update #local set ntokens=ntokens+1

        update #local set i=0
        while 1=(select case when i<rule_nsymbol then 1 else 0 end from #local)
            begin
            update #local set nstack=nstack-1
            -- push element into reduction tree
            -- declare @id int,@stack_id int

            -- move from stack to reduction tree (_push_rt_element(...stack[nstack-1])
            -- update #rt set nrtchild=1 where id=2
            insert #rt(
                id,symbol,token,lexeme,
                [state],[rule],nrtchild,
                row,col
                )
            select
                #local.rtofs,#stack.symbol,#stack.token,#stack.lexeme,
                #stack.[state],#stack.[rule],#stack.nrtchild,
                #stack.row,#stack.col
            from #stack ,#local
            where #stack.id=#local.nstack

            -- move rtchildren from stack to rt
            insert #rt_child(rid,idx,val)
            select #local.rtofs,#stack_child.idx,#stack_child.val
            from #stack_child,#local
            where #stack_child.rid=#local.nstack

            -- -1 means alone; will be attached
            insert #stack_child(rid,idx,val)
            select -1,#local.i,#local.rtofs
            from #local

            update #local set rtofs=rtofs+1 -- same of rtofs

            -- revert lalr state
            update #local set
                lalr_state=stack.[state]
            from #local,#stack stack
            where stack.id=#local.nstack

            -- pop stack
            delete #stack from #stack,#local where #stack.id=#local.nstack
            delete #stack_child from #stack,#local where #stack_child.rid=#local.nstack

            update #local set i=i+1
            end -- for/while i<rule_nsymb      -- end -- if rule_nsymbol

        -- get symbol information  (parser_get_symbol(parser,rule->nonterminal,sym,rtIdx,..)
        update #local set
            sym_name=#sym.[name],sym_type=#sym.[type]
        from #sym,#local
        where #sym.id=#local.symbol

        -- push non terminal onto stack

        insert #stack(
            id,
            symbol,token,
            lexeme,[state],[rule],nrtchild,
            row,col
            )
        select #local.nstack,
               #local.symbol, #local.rule_nonterminal,
               #local.lexeme, #local.lalr_state, #local.reduce_rule,#local.rule_nsymbol,
               #local.token_row,#local.token_col
        from #local

        -- attach local rtIdx
        update #stack_child set rid=#local.nstack
        from #local
        where rid=-1

        -- Reduction tree head (always parser->rt[0])
        -- _set_rt_head(parser, parser->stack+(parser->nstack-1));
        update #rt set
            symbol  = stack.symbol,
            token   = stack.token,
            [rule]  = stack.[rule],
            [state] = stack.state,
            lexeme  = stack.lexeme,
            nrtchild = stack.nrtchild,
            row     = stack.row,
            col     = stack.col
        from #local,#rt rt,#stack stack
        where rt.id=0 and stack.id=#local.nstack

        -- copy stack.rtchildren into rt[0]
        delete #rt_child where rid=0
        insert #rt_child select 0,#stack_child.idx,#stack_child.val
        from #stack_child,#local
        where #stack_child.rid=#local.nstack
        -- free(@sym_name)

        update #local set nstack=nstack+1, reduction=0

        end -- if reduction
')

--  drop proc #dbg
exec('create proc #dbg @what sysname=null as
    declare @sql nvarchar(4000)
    exec sp__select_astext ''
        select
            i,c,rule_nonterminal,parse,reduction,row,nofs,lexeme,
            symbol,sym_name,lalr_state,nstack,rtofs,a_action,ntokens,buffer
        from #local''
    if @what=''#local'' select * from #local
    if @what=''#sym'' select * from #sym order by id
    if @what=''#stack''
        select *
        from #stack s
        left join #stack_child sc on s.id=sc.rid
        left join #sym sy on s.symbol=sy.id
        order by s.id,sc.idx

    select @sql=''
        select
            dbo.fn__pad(r.id,2,default,default,default) id,r.symbol,r.token,r.lexeme,
            r.[state],r.[rule],r.nrtchild,/*rc.idx,rc.val,*/sy.name,sy.type,
            r.row,r.col
        from #local,#rt r
        /* left join #rt_child rc on r.id=rc.rid */
        left join #sym sy on r.symbol=sy.id
        where r.id<#local.rtofs
        order by 1/*,8*/
    ''

    if @what is null
        exec sp__select_astext @sql
    if @what=''#rt'' exec(@sql)

    if @what=''#token'' select * from #token
    return 1
')

insert #rt(id,symbol,token,lexeme,[state],[rule],nrtchild)
select 0,0,0,null,0,0,0

-- close src deallocate src
declare src cursor /*local for debug*/ FORWARD_ONLY READ_ONLY for
    select lno,line
    from #src
    order by lno
open src

-- declare @run int,@out sysname
select @run=1
while (@run=1)
    begin

    -- #reset  -- set nocount on
    exec #reduction -- select * from #sym

    -- to dbg: run this 3 times to have a reduction rule
    exec #parse -- return rule_nonterminal or 0; if reduction!=0 got above
    -- exec #scanner_scan select c,#token.* from #token,#local

    -- in main
    if (select parse from #local)<0
        begin
        exec #dbg
        exec sp__printf 'error parsing'
        select r.* from #rule_definition r,#local l
        where r.[index] in (l.rule_nonterminal,l.reduce_rule)
        select * from #local
        select @run=0
        end
    if (select parse from #local)=0
        begin
        if (select dbg from #local)=1 exec #dbg '#rt' -- select * from #stack
        -- if not @out is null exec('select * into '+@out+' from #rt')
        select @run=0
        end

    end -- while run=1

close src
deallocate src

-- print _rt_tree
exec('
create proc #print_rt_tree @rtpos int=0,@indent int=-1
as
begin
declare
    @i int,@j int,@s sysname,@t sysname,@p int,@type int,
    @l nvarchar(4000),@r smallint,@c smallint

select @indent=@indent+1,@l=replicate(''| '',@indent)

select
    @i=0,
    @j=nrtchild-1,
    @s=#sym.name,
    @t=#rt.lexeme
from #rt join #sym on #rt.symbol=#sym.id
where #rt.id=@rtpos

/*
    reduction trim: trim reductions which contain only one non-terminal.

    not trimmed:
    +--<Statements> ::= <Statement>
    |  +--<Statement> ::= assign Id ''='' <Expression>
    |  |  +--assign
    |  |  +--a
    |  |  +--=
    |  |  +--<Expression> ::= <Add Exp>
    |  |  |  +--<Add Exp> ::= <Mult Exp>
    |  |  |  |  +--<Mult Exp> ::= <Negate Exp>
    |  |  |  |  |  +--<Negate Exp> ::= <Value>
    |  |  |  |  |  |  +--<Value> ::= Id
    |  |  |  |  |  |  |  +--b

    trimmed:
    +--<Statement> ::= assign Id ''='' <Expression>
    |  +--assign
    |  +--a
    |  +--=
    |  +--<Value> ::= Id
    |  |  +--b
*/

exec sp__printf ''%s+-<%s> :: = %s'',@l,@s,@t

declare cs cursor local for
    select val
    from #rt_child rc
    where rc.rid=@rtpos
    order by idx desc
open cs
while 1=1
    begin
    fetch next from cs into @p
    if @@fetch_status!=0 break

    select
        @type=#sym.[type],
        @s=#sym.name,
        @t=#rt.lexeme,
        @r=row,@c=col
    from #rt
    join #sym on #rt.symbol=#sym.id
    where #rt.id=@p

    if @type!=1 -- non terminal
        exec #print_rt_tree @p,@indent
    else
        exec sp__printf ''%s+-<%s> :: = %s (%d,%d)'',@l,@s,@t,@r,@c

    end -- while of cursor
close cs
deallocate cs

end -- #print_rt_tree
')

exec #print_rt_tree

drop proc #print_rt_tree
drop proc #dbg
drop proc #reduction
drop proc #parse
drop proc #scanner_scan
drop proc #reset
drop proc #match_token
drop proc #scanner_get_char


-- print tree

goto ret

help:
exec sp__usage @proc,'

Inputs
    #src                source code
    @cgt or #blob       the cgt file or data loaded
    #cb_matchtoken      callback sp

Output
    #tr_symbols         list of symbols

Defnitions

    create table #src(lno int identity,line nvarchar(4000))

'

ret:
return @ret
end -- sp__parse_gold
