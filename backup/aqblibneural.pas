unit aqBlibNeural;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, Math;

type

  ArrDouble = array of double;
  ArrInteger = array of integer;



  Tcoluna = record
    Coluna: string;
    valores: arrdouble;
    idColunaDados: integer;
  end;

  tcamadaConf = record
    neuronios: integer;
    funcao: char;
  end;

  tcamadaConf1 = record
    tccf: array of tcamadaConf;
  end;




  { tNeu }

  tNeu = class(TObject)
  private
    w: arrdouble;

  public
    d: double;
    ativacao: char;
    constructor Create(fativacao: char);
    procedure Calcular_d(entrada: arrdouble);



  end;


  { tCamada }

  tCamada = class(TObject)
  private



  public
    ativacao1: char;
    neus: array of tNeu;
    function ValoresD: arrdouble;
    function Ds: arrdouble;
    constructor Create(CtNeus: tcamadaConf);


  end;



  { tIndiv }

  tIndiv = class(TObject)
  private


  public
    erro: double;
    // maxErro:double;
    geracoes1: array of integer;
    camadas: array of tcamada;
    function SalvarPesosTab(): string;
    function salvarPesos(): string;
    function CalcularSaidas(fentrada: ArrDouble): ArrDouble;
    procedure reproduzir(fpai: tindiv);
    function vergeracores(): string;
    procedure CalculaErro(fentradas, fsaidas: array of tcoluna);
    constructor Create(fCamadas: tcamadaConf1; fidIndiv: integer);
    function CalculaDiferenca(fentradas, fsaidas: array of tcoluna): string;

  end;

  fAtivacao = function(soma, w: double): double;

function de1a1(): double;
function aleatorio(fmin, fmax: integer): integer;
function n2alfa(fnum: integer): string;

function a_atvLinear(soma, w: double): double;
function b_atvSigmode(soma, w: double): double;
function C_atvDegral(soma, w: double): double;

function a_atvLineartx(fw, fx: array of string): string;
function b_atvSigmodetx(fw, fx: array of string): string;
function C_atvDegraltx(fw, fx: array of string): string;



const
  letraatv: array[0..2] of char = ('a', 'b', 'c');
  primo: integer = 104729;

implementation

uses aqinicio;

function de1a1(): double;
begin
  Result := (Random * 2) - 1;
end;

function aleatorio(fmin, fmax: integer): integer;
var
  rand: integer;
begin
  Randomize;
  rand := Random(fmax - fmin + 1);
  Result := fmin + rand;
end;

function n2alfa(fnum: integer): string;
const
  letras: string = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
begin
  Result := '';
  while fnum > 0 do
  begin
    Result := letras[fnum mod 26] + Result;
    fnum := fnum - (fnum mod 26);
    fnum := fnum div 26;
  end;

end;

function a_atvLinear(soma, w: double): double;
begin
  Result := soma * w;
end;

function b_atvSigmode(soma, w: double): double;
const
  eu: double = 2.718281828459045235360287471352662497757;
begin
  Result := (2 / (1 + power(eu, (-2 * soma)))) - 1;
  Result := Result * w;
end;

function C_atvDegral(soma, w: double): double;
begin
  if soma >= 0 then
  begin
    Result := 1;
  end
  else
  begin
    Result := -1;
  end;

  Result := Result + w;

end;

function a_atvLineartx(fw, fx: array of string): string;
var
  fi: integer;
begin
  fi := 0;
  Result := '=(';
  while True do
  begin
    Result := Result + '(' + fw[fi] + '*' + fx[fi] + ')';
    Inc(fi);
    if fi = Length(fx) then
      Break;
    Result := Result + '+';
  end;
  Result := Result + ')*' + fw[fi];
end;

function b_atvSigmodetx(fw, fx: array of string): string;
var
  fi: integer;
begin
  fi := 0;
  Result := '(';
  while True do
  begin
    Result := Result + '(' + fw[fi] + '*' + fx[fi] + ')';
    Inc(fi);
    if fi = Length(fx) then
      Break;
    Result := Result + '+';
  end;
  Result := Result + ')';

  Result := '=((2/(1+(EXP(1)^(-2*' + Result + '))))-1)*' + fw[fi];

end;

function C_atvDegraltx(fw, fx: array of string): string;
var
  fi: integer;
begin
  fi := 0;
  Result := '(';
  while True do
  begin
    Result := Result + '(' + fw[fi] + '*' + fx[fi] + ')';
    Inc(fi);
    if fi = Length(fx) then
      Break;
    Result := Result + '+';
  end;
  Result := Result + ')';


  Result := '=' + fw[fi] + '*SE(' + Result + '>=0;1;-1)';

end;




{ tIndiv }

function tIndiv.SalvarPesosTab(): string;
var
  tx: TStringList;
  fi, fi1, fi2, fi3, fi4: integer;
  linha, palavra: string;
  fw,fx: array of string;

begin
  tx := TStringList.Create;

  tx.Add('Atta engenharia!');      //1

  tx.Add('');

  linha := #9;
  fi := 0;
  while fi < length(trEntradas) do
  begin
    linha := linha+trEntradas[fi].Coluna+#9;
    inc(fi);
  end;
  tx.Add(linha);

  tx.Add('X(' + IntToStr(length(self.camadas[0].neus)) + ')=');  //3

  tx.Add('');

  fi := 0;

  while fi < length(self.camadas) do
  begin
    tx.Add('Camada ' + IntToStr(fi));
    fi1 := 0;
    while fi1 < length(self.camadas[fi].neus[0].w) do
    begin
      fi2 := 0;
      linha := 'W(' + IntToStr(fi1) + ')' + #9;
      while fi2 < length(self.camadas[fi].neus) do
      begin
        linha := linha + floattostr(self.camadas[fi].neus[fi2].w[fi1]) + #9;
        Inc(fi2);
      end;
      tx.Add(linha);

      Inc(fi1);
    end;

    setlength(fx,length(self.camadas[fi].neus[0].w)-1);
    setlength(fw,length(self.camadas[fi].neus[0].w));

    fi3 := 0;
    while fi3 < length(fx) do
    begin
      fx[fi3] := n2alfa(fi3+2)+inttostr(tx.Count-length(fx)-3);
      inc(fi3);
    end;

    linha := 'D=' + #9;
    fi4 := 0;
    while fi4 < fi2 do
    begin
      fi3 := 0;
      while fi3 < fi1 do
      begin
          fw[fi3] := n2alfa(fi4+2)+
                     inttostr(tx.Count-length(fx)+fi3);
        Inc(fi3);
      end;

         case self.camadas[fi].neus[fi4].ativacao of
    'a': palavra := a_atvLineartx(fw,fx);
    'b': palavra := b_atvSigmodetx(fw,fx);
    'c': palavra := c_atvdegraltx(fw,fx);
  end;



      linha := linha +palavra+ #9;

      Inc(fi4);
    end;

    tx.Add(linha);
    tx.Add('');

    Inc(fi);
  end;

    tx.Add('');
    linha := #9;
    palavra := 'Y='+#9;

    //valores de saida
    fi := 0;
    while fi < length(trSaidas) do
    begin
      linha := linha+trSaidas[fi].Coluna+#9;
      palavra := palavra+
               '='+n2alfa(fi+2)+ IntToStr(tx.Count-2)+#9;
      inc(fi)
    end;

    tx.Add(linha);
    tx.Add(palavra);




  Result := tx.Text;
  tx.Free;

end;

function tIndiv.salvarPesos(): string;
var
  fcm, fneu, fw: integer;
  ftx: TStringList;
  linha: string;
begin
  ftx := TStringList.Create;

  fcm := 0;
  while fcm < length(self.camadas) do
  begin
    fneu := 0;
    while fneu < length(self.camadas[fcm].neus) do
    begin
      linha := '' + IntToStr(fcm) + ';' + self.camadas[fcm].ativacao1 +
        ';' + IntToStr(fneu) + '|';

      fw := 0;
      while True do
      begin
        linha := linha + floattostr(self.camadas[fcm].neus[fneu].w[fw]);

        Inc(fw);
        if fw = length(self.camadas[fcm].neus[fneu].w) then
          Break;

        linha := linha + ';';
      end;
      linha := linha + '';
      ftx.Add(linha);
      Inc(fneu);
    end;

    Inc(fcm);
  end;



  // jinicio.Memo1.Lines.Add(ftx.Text);;
  ftx.SaveToFile(jinicio.cArquivo.Text + '.pesos.txt');
  ftx.Free;

end;



procedure tIndiv.reproduzir(fpai: tindiv);
var
  icm, ineu, iw: integer;
  fvalor: double;
  fi: integer;
begin

  if fpai.Erro > self.erro then
    exit; // Sai se o erro maior

  //Ajustar valores de pesos

  icm := 0;
  while icm < length(self.camadas) do
  begin
    ineu := 0;
    while ineu < length(self.camadas[icm].neus) do
    begin
      iw := 0;
      while iw < length(self.camadas[icm].neus[ineu].w) do
      begin
        fvalor := 0;
        if (Random * 100) < jInicio.cProbabilidade.Value then
        begin
          fvalor :=
            fpai.camadas[icm].neus[ineu].w[iw] * de1a1() * jinicio.cEscala.Value;
        end;

        self.camadas[icm].neus[ineu].w[iw] :=
          strtofloat(FormatFloat('0.00E+00', fvalor +
          fpai.camadas[icm].neus[ineu].w[iw]));
        // mutacao

        //arredondar
        //  self.camadas[icm].neus[ineu].w[iw] :=
        //  RoundTo(self.camadas[icm].neus[ineu].w[iw],5);

        Inc(iw);
      end;

      Inc(ineu);
    end;
    Inc(icm);
  end;


  //REgistrar Gerações

  setlength(self.geracoes1, length(fpai.geracoes1) + 1);
  fi := 0;
  while fi < length(fpai.geracoes1) do
  begin
    self.geracoes1[fi + 1] := fpai.geracoes1[fi];
    Inc(fi);
  end;

end;

function tIndiv.vergeracores(): string;
var
  fi: integer;
begin
  exit;
  fi := 0;
  Result := '';
  while fi < length(self.geracoes1) do
  begin
    Result := Result + IntToStr(self.geracoes1[fi]) + ' ';
    Inc(fi);
  end;

end;

function tIndiv.CalcularSaidas(fentrada: ArrDouble): ArrDouble;
var
  fi1, fi2: integer;
begin

  //Calcular primeira camada
  fi1 := 0;
  while fi1 < length(self.camadas[0].neus) do
  begin
    self.camadas[0].neus[fi1].Calcular_d(fentrada);
    Inc(fi1);
  end;

  //Calcular restante das camadas
  fi1 := 1;
  while fi1 < length(self.camadas) do
  begin
    fi2 := 0;
    while fi2 < length(self.camadas[fi1].neus) do
    begin
      self.camadas[fi1].neus[fi2].
        Calcular_d(self.camadas[fi1 - 1].ValoresD);
      Inc(fi2);
    end;

    Inc(fi1);
  end;

  //Ver diferença
  fi1 := fi1 - 1;
  SetLength(Result, length(self.camadas[fi1].neus));
  fi2 := 0;
  while fi2 < length(self.camadas[fi1].neus) do
  begin
    Result[fi2] := self.camadas[fi1].neus[fi2].d;
    Inc(fi2);
  end;

end;




procedure tIndiv.CalculaErro(fentradas, fsaidas: array of tcoluna);
var
  fi, fi1, fi2: integer;
  flentra, flSai: arrdouble;
  errot: double;
begin
  self.erro := 0;


  //alocar tamanho
  setlength(flentra, length(fentradas));

  //Inicier ciclo
  fi := 0;
  while fi < length(fentradas[0].valores) do
  begin
    fi1 := 0;
    while fi1 < length(flentra) do
    begin
      flentra[fi1] := fentradas[fi1].valores[fi];
      Inc(fi1);
    end;

    //---------------------------------------------------------
    flSai := self.CalcularSaidas(flentra);


    //Ver diferença
    fi2 := 0;
    errot := 0;
    while fi2 < length(flSai) do
    begin
      errot := errot + abs((flSai[fi2] - fsaidas[fi2].valores[fi])/(fsaidas[fi2].valores[fi]+0.001));

      Inc(fi2);
    end;

    self.erro := self.erro;// + power(errot, 0.5);

    Inc(fi);
  end;


  //---------------------------------------------------------------

  self.erro := self.erro / length(fentradas[0].valores);


  //erro global
  if self.erro < jinicio.erroglob then
  begin
    jinicio.erroglob := self.erro;
    jinicio.iderroglob := self.geracoes1[0];

    jinicio.Memo1.Lines.Add('Erro : ' + floattostr(jinicio.erroglob) +
      self.vergeracores());
  end;

end;

constructor tIndiv.Create(fCamadas: tcamadaConf1; fidIndiv: integer);
var
  fi: integer;
begin
  setlength(self.camadas, length(fcamadas.tccf));
  fi := 0;
  while fi < length(fcamadas.tccf) do
  begin
    self.camadas[fi] := tcamada.Create(fcamadas.tccf[fi]);
    Inc(fi);
  end;

  setlength(self.geracoes1, 1);
  self.geracoes1[0] := fidIndiv;

end;

function tIndiv.CalculaDiferenca(fentradas, fsaidas: array of tcoluna): string;
  ///////////////////////////////////
var
  fi, fi1, fi2: integer;
  ftemp: arrdouble;
  ftx: TStringList;
  linha: string;
  mds: array of array of double;
begin

  //Fazer lista dos arrays
  setlength(mds, length(fsaidas));
  fi1 := 0;
  while fi1 < length(mds) do
  begin
    setlength(mds[fi1], length(fentradas[0].valores));
    Inc(fi1);
  end;


  ftx := TStringList.Create;


  //alocar tamanho
  setlength(ftemp, length(fentradas));

  //Inicier ciclo
  fi := 0;
  while fi < length(fentradas[0].valores) do
  begin
    fi1 := 0;
    while fi1 < length(ftemp) do
    begin
      ftemp[fi1] := fentradas[fi1].valores[fi];
      Inc(fi1);
    end;

    //Calcular primeira camada
    fi1 := 0;
    while fi1 < length(self.camadas[0].neus) do
    begin
      self.camadas[0].neus[fi1].Calcular_d(ftemp);
      Inc(fi1);
    end;

    //Calcular restante das camadas
    fi1 := 1;
    while fi1 < length(self.camadas) do
    begin
      fi2 := 0;
      while fi2 < length(self.camadas[fi1].neus) do
      begin
        self.camadas[fi1].neus[fi2].
          Calcular_d(self.camadas[fi1 - 1].ValoresD);
        Inc(fi2);
      end;

      Inc(fi1);
    end;

    //Ver diferença
    fi1 := fi1 - 1;
    fi2 := 0;
    while fi2 < length(self.camadas[fi1].neus) do
    begin
      mds[fi2, fi] := self.camadas[fi1].neus[fi2].d;

      Inc(fi2);
    end;


    Inc(fi);
  end;


  fi1 := 0;
  while fi1 < length(fsaidas) do
  begin
    ftx.Add('');
    ftx.Add('Coluna ' + fsaidas[fi1].Coluna);
    fi2 := 0;
    while fi2 < length(fsaidas[fi1].valores) do
    begin
      linha := floattostr(fsaidas[fi1].valores[fi2]) + ' - ' +
        floattostr(mds[fi1, fi2]) + ' = ' +
        floattostr(fsaidas[fi1].valores[fi2] - mds[fi1, fi2]) + ' / ' +
        formatfloat('0.00', (fsaidas[fi1].valores[fi2] - mds[fi1, fi2]) *
        100 / fsaidas[fi1].valores[fi2]) + '%';
      ftx.Add(linha);
      Inc(fi2);
    end;

    Inc(fi1);
  end;


  Result := ftx.Text;
  ftx.Free;

end;

{ tCamada }

function tCamada.ValoresD: arrdouble;
var
  fi: integer;
begin
  setlength(Result, length(self.neus));
  fi := 0;
  while fi < length(Result) do
  begin
    Result[fi] := self.neus[fi].d;
    Inc(fi);
  end;

end;

function tCamada.Ds: arrdouble;
var
  fi: integer;
begin
  setlength(Result, length(self.neus));
  fi := 0;
  while fi < length(self.neus) do
  begin
    Result[fi] := self.neus[fi].d;
    Inc(fi);
  end;
end;

constructor tCamada.Create(CtNeus: tcamadaConf);
var
  fi: integer;

begin
  setlength(self.neus, CtNeus.neuronios);
  self.ativacao1 := ctneus.funcao;

  fi := 0;
  while fi < ctneus.neuronios do
  begin
    self.neus[fi] := tneu.Create(self.ativacao1);

    Inc(fi);
  end;

end;




{ tNeu }

constructor tNeu.Create(fativacao: char);
begin

  if fativacao = 'z' then
  begin
    fativacao := letraatv[aleatorio(0, Length(letraatv) - 1)];

  end;

  self.ativacao := fativacao;

end;

procedure tNeu.Calcular_d(entrada: arrdouble);
var
  fi: integer;
  soma: double;
begin
  //Verificar tamanho de w
  if (length(entrada) > (length(self.w) - 1)) then
  begin
    setlength(self.w, length(entrada) + 1);

    fi := 0;
    while fi < length(self.w) do
    begin
      self.w[fi] := 0.1; //start de W
      Inc(fi);
    end;

  end;

  //Calcular soma
  fi := 0;
  soma := 0;
  while fi < length(entrada) do
  begin
    soma := soma + (entrada[fi] * self.w[fi]);
    Inc(fi);
  end;

  case self.ativacao of
    'a': self.d := a_atvLinear(soma, self.w[fi]);
    'b': self.d := b_atvSigmode(soma, self.w[fi]);
    'c': self.d := c_atvdegral(soma, self.w[fi]);
  end;

end;




end.



















