unit aqPopulacao;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, aqblibneural, fpjson;

type

  { tTreinamento }

  tTreinamento = class(TThread)
  private
    entradas, saidas: array of tcoluna;
    tamanho: integer;
    indiv: array of tIndiv;
    camadas: tcamadaConf1;
    Ciclos: integer;

  protected
    procedure Execute; override;
  public
    constructor Create(fentradas, fsaidas: array of tcoluna;
      ftamanho: integer; fCamadas: tcamadaConf1; fciclos: integer);

  end;


implementation

uses aqinicio;

{ tTreinamento }



procedure tTreinamento.Execute;
var
  fi: integer;
  num: integer;
begin

  fi := 0;
  while ((fi < self.Ciclos) and (jinicio.cPara.Enabled)) do
  begin

    //reproduzir
    Randomize;
    num := Random(length(self.indiv));
    self.indiv[(num - 2 + length(self.indiv)) mod length(self.indiv)].reproduzir(
      self.indiv[num]);
    self.indiv[(num - 2 + length(self.indiv)) mod length(self.indiv)].CalculaErro(
      self.entradas, self.saidas);

    self.indiv[(num - 1 + length(self.indiv)) mod length(self.indiv)].reproduzir(
      self.indiv[num]);
    self.indiv[(num - 1 + length(self.indiv)) mod length(self.indiv)].CalculaErro(
      self.entradas, self.saidas);

    self.indiv[(num + 1 + length(self.indiv)) mod length(self.indiv)].reproduzir(
      self.indiv[num]);
    self.indiv[(num + 1 + length(self.indiv)) mod length(self.indiv)].CalculaErro(
      self.entradas, self.saidas);

    self.indiv[(num + 2 + length(self.indiv)) mod length(self.indiv)].reproduzir(
      self.indiv[num]);
    self.indiv[(num + 2 + length(self.indiv)) mod length(self.indiv)].CalculaErro(
      self.entradas, self.saidas);

    Inc(fi);
  end;


  self.indiv[jinicio.iderroglob].salvarPesos();
  jinicio.Memo1.Lines.Add(
    self.indiv[jinicio.iderroglob].CalculaDiferenca(self.entradas, self.saidas)
    );

  try
    jinicio.vindiv.Free;
  except
  end;

  jinicio.vindiv := self.indiv[jinicio.iderroglob];

end;

constructor tTreinamento.Create(fentradas, fsaidas: array of tcoluna;
  ftamanho: integer; fCamadas: tcamadaConf1; fciclos: integer);


var
  fi: integer;
begin
  //carregar entradas e saidas
  setlength(self.entradas, length(fentradas));
  fi := 0;
  while fi < length(fentradas) do
  begin
    self.entradas[fi] := fentradas[fi];
    Inc(fi);
  end;

  setlength(self.saidas, length(fsaidas));
  fi := 0;
  while fi < length(fsaidas) do
  begin
    self.saidas[fi] := fsaidas[fi];
    Inc(fi);
  end;


  // Carregar tamanho
  self.tamanho := ftamanho;
  fi := 0;
  setlength(self.indiv, self.tamanho);

  //Carregar camadas

  setlength(self.Camadas.tccf, length(fcamadas.tccf) + 1);
  fi := 0;
  while fi < length(fcamadas.tccf) do
  begin
    self.camadas.tccf[fi] := fcamadas.tccf[fi];
    Inc(fi);
  end;
  self.camadas.tccf[length(fcamadas.tccf)].neuronios := length(self.saidas);
  self.camadas.tccf[length(fcamadas.tccf)].funcao := 'a';


  //e Criar populacão
  fi := 0;
  while fi < self.tamanho do
  begin
    self.indiv[fi] := tindiv.Create(self.camadas, fi);
    self.indiv[fi].CalculaErro(self.entradas, self.saidas);
    Inc(fi);
  end;

  //Carregar ciclos
  self.Ciclos := fciclos;



  //---------[ Inicializar ] ---
  self.FreeOnTerminate := True;

  case jInicio.cPrio.ItemIndex of
    0: self.Priority := tpIdle;
    1: self.Priority := tpLowest;
    2: self.Priority := tpLower;
    3: self.Priority := tpNormal;
    4: self.Priority := tpHigher;
    5: self.Priority := tpHighest;
    6: self.Priority := tpTimeCritical;
  end;



  inherited Create(True);
  self.Resume;
end;


end.
