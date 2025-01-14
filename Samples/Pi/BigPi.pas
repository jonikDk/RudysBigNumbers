{===============================================

 Included with Rudy's Big Numbers Library
 https://github.com/TurboPack/RudysBigNumbers/

================================================}
unit BigPi;

interface

uses
  SysUtils,
  Math,
  Velthuis.BigDecimals,
  Velthuis.BigIntegers;

type TDigits = Array of Byte;
const MaxUnit64 = 18_446_744_073_709_551_615;

function BBPpi(Places: UInt64): TDigits;
function Chudnovsky(Places: Integer): BigDecimal;
function DigitsToString(Digits: TDigits): String;

implementation

function BBPpi(Places: UInt64): TDigits;
// Bailey-Borwein-Plouffe
begin
  SetLength(Result, Places);

  var idx: Uint64 := 0;
  var q := BigInteger.One;
  var r := BigInteger.Zero;
  var t := BigInteger.One;
  var k := BigInteger.One;
  var n := BigInteger.Create(3);
  var l := BigInteger.Create(3);

  while true do
  begin
    if 4*q+r-t < n*t then
    begin
      result[idx] := n.AsInt64; // It is just a byte
      inc(idx);
      //write(n.ToString[1]);
      if idx >= places then break;
      var newR := 10 * (r - n * t);
      n := ((10 * (3 * q + r)) div t) - 10 * n;
      q := q * 10;
      r := newR;
    end
    else
    begin
      var newR := (2 * q + r) * l;
      var newN := (q * (7 * k)+2+(r * l)) div (t * l);
      q := q * k;
      t := t * l;
      l := l + 2;
      k := k + 1;
      n := newN;
      r := newR;
    end;
  end;
end;

function Chudnovsky(Places: Integer):BigDecimal;
begin
  // Use +6 internally for calculations
  var internalPrecision := MaxInt;
  if Places <= MaxInt - 6 then
    internalPrecision := Places + 6;

  var lastSum: BigDecimal;
  var t := BigDecimal.Create(3);
  var sum := BigDecimal.Create(3);
  sum.DefaultPrecision := internalPrecision;
  sum.DefaultRoundingMode := rmFloor;
  var n := BigInteger.One;
  var d := BigInteger.Zero;
  var na: UInt64 := 0;
  var da: UInt64 := 24;
  while sum <> lastSum do
  begin
    lastSum := sum;
    n := n + na;
    na := na + 8;
    d := d + da;
    da := da + 32;
    t := ((t * n)/d);
    sum := (sum + t).RoundToPrecision(internalPrecision);
  end;
  Result := sum.RoundToPrecision(Places);
end;

function DigitsToString(digits: TDigits): String;
begin
  SetLength(Result, Length(Digits));
  for var idx: Integer := 0 to pred(Length(Digits)) do
  begin
    Result[idx+1] := Digits[idx].ToString[1];
  end;
  Result := Result.Insert(1,'.');
end;

end.
