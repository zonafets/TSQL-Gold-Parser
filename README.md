# TSQL-Gold-Parser
TSQL stored procedure to load Gold-Parser compiled grammar, analyze sources and store symbols into persisting table.

See http://www.goldparser.org/ .

The goal of this personal project was to develop a Rule Engine to transpile into TSQL, VB/C# code for the application.

**Since the working conditions have changed, the project has been abandoned and I decided to open source it.**

**But** after that I have put on the screen of my mind some equation.

* for about thirty years have been attempted to kill the C

* many old and new programming languages (freepascal, GO, etc.) start with a base compiler written in C

* the base compiler compile a new advanced compiler that manage OOP, generics, templates, etc.

* for about 3 days I try to print an HTML page with correct margins
  * I do not understand yet if the problem was:
    * the W3C documentation or one of the many tutorials without examples
    * the CSS version itself or Chrome
    * the Chrome print panel (and then I'll try Firefox, Safari, Opera, Midori, IE, EG, ... )
  * with MSAccess I would have spent a few minutes
  * a user with Libreoffice Writer would have spent half a day
  * a working command-line utility would have solved any doubt even if in its own way 

* when will it be that browsers will really do everything with HTML and Javascript (traspiled) what todays  OS, IDE, Mobile Apps and GPU do?

* [TCC](https://bellard.org/tcc/) is a  small cross platform C compiler (20KB exe + 150KB dll + 1MB basic def/lib )

  * it is super faster
  * it compile (.exe or .elf), link (.lib, .a, .dll) and execute in a single step so can be used for C scripts
  * it uses it self to compile and can compile it self

* SQLite uses the [Lemon parser](https://www.sqlite.org/src/doc/trunk/doc/lemon.html), written in C, to generate a C code to parse SQL that call C functions of the engine but that do not compile expressions as "SELECT x+y"

* the Windows ODBC driver for SQLite, integrates TCC lib to expand SQL functions

* no new paradigm has eliminated or reduced programming errors more than the 

  personal experience or the assistance of an expert tool or IDE

* Emscripten is a **tool** that use CLang **tools** to compile C/C++ or X language to PCODE for a sub VM of Javascript VM that:

  * is 2x faster
  * resolve problems of lack of strict types of javascript
  * recycle old code

* every new programming paradigm creates new ambiguities

  * i think that **Gödel's incompleteness theorems** is valid for any language
  * C++ templates required 30th to evolve
    * C macros require less than 20 lines of text to learn how they work and what to careful, that means that the experience can be widely shared, with a server too
    * C++ templates are Turing-complete, require [11 pages](http://www.aristeia.com/Papers/C++ReportColumns/jan95.pdf) to understand a small possible use
    * even if today they are compiled [faster](https://hackernoon.com/comparing-the-compilation-times-of-templates-and-macros-d0a1b7264a17) , was an IDE that indtroduces me to C#
  * **today RUST claim to be better tha C++**

* Golden Parser has a nice grammar editor and compiler, [LALR state browser and interactive testing system](http://goldparser.org/builder/screenshots.htm)

* it seems that nobody has thought about using the LALR states for the syntax highlighting

* I remember that my first C compiler for the Z80 CPU (praise to [Federico Faggin](https://en.wikipedia.org/wiki/Federico_Faggin)) Sega/MSX, optionally wrote the table of symbols to file

* with C# was made interesting things using its reflection

* with C++/C# can write the same thing in different ways (N) with different models (N ^ M)

* call a C function from any language is possible and simple, not the contrary

* not enough 200 engineers and NASA procedures to avoid a trivial error, cost $ 800,000

* it seems that we are creating complex things to write in a complex way to avoid trivial errors

  * sounds strange, isn't it? One comes to think of the **Heisenberg's uncertainty principle**


So I imagined what would happen if there was something like this:

```C
/* simplify and expand inclusion */
#include stdLib,"http:\\stdC\libs\stdIO" // .gz, .lib, .a, .dll or .typ or .tpu

/* introducing syntax to prevent the satellites from crash */
#grammar um {
	...
	expr ::= expr PLUS expr.   { printf("Doing an addition...\n"); }
	...
}

#grammar sql(database db) {
	...
}

int main() {
  database db, float m,s,v;

  um(m,s,v) {
    meters m = 10;
    seconds s = 5;
    velocity v = s/m;		// error!
  }
  
  sql(db,m,s,v) {
    insert into table values(m,s,v);
  }
  
  printf("Value of v is %f", v)
}
```

Maybe are at least required:

* the overloading of cast operator
* the "extensions" syntax  p1.function(...) -> function(p1, ... ) 
  * to avoid use of constructor, polymorphism, *, ->,  

```C
#include htmlGrammar

int crc32(char *str) {...}

int operator=(object &o,char* init) {...}
int operator+(object &o,int value) {...}
operator int(object &o) {...}

int main() {
  object o = "meter m = 10";
  int x = o + 10;
  int passpwd = #crc32("compiled and linked at compile time");
  
  // the parser can be used as template engine?
  char *id = "me"
  DOM nodes;
    
  nodes = html(id) {
    <label for "@id">Name:</lable>
    <input id="@id">
  }
}
```

Why this cannot be an italian project? Because we spend more time learning new features, languages and tools rather than computerizing the country.

