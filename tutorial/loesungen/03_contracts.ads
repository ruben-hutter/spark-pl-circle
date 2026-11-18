--  Kapitel 3: Kontrakte (Lösung)

package Contracts
  with SPARK_Mode
is

   function Absolute_Value (X : Integer) return Integer
   with
     Pre  => X /= Integer'First,
     Post =>
       Absolute_Value'Result >= 0
       and then (Absolute_Value'Result = X or else Absolute_Value'Result = -X);

   --  a) B > 0 statt B /= 0: schliesst division by zero UND den
   --    Overflow-Fall Integer'First / -1 aus.
   procedure Divide (A, B : Integer; Q : out Integer)
   with Pre => B > 0, Post => Q = A / B;

   --  b) Bug gefixt: >= statt >.
   procedure Is_Adult (Age : Natural; Adult : out Boolean)
   with Post => Adult = (Age >= 18);

   --  c) Pre: Maximum > 0 (division by zero, siehe a)), Remaining <=
   --    Maximum (ein Anteil ist höchstens das Ganze) und Remaining <=
   --    Natural'Last / 100, sonst überläuft das Zwischenergebnis
   --    Remaining * 100 (das Resultat passt dann immer).
   function Percent (Remaining, Maximum : Natural) return Natural
   with
     Pre  =>
       Maximum > 0
       and then Remaining <= Maximum
       and then Remaining <= Natural'Last / 100,
     Post => Percent'Result = (Remaining * 100) / Maximum;

   --  d) Dritter Fall ergänzt, jetzt lückenlos und ohne Überlappung.
   procedure Sign (X : Integer; S : out Integer)
   with Contract_Cases => (X > 0 => S = 1, X = 0 => S = 0, X < 0 => S = -1);

   procedure Client;

end Contracts;
