unit aqInicio;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TASeries, Forms, Controls, Graphics,
  Dialogs, StdCtrls, ExtCtrls, CheckLst, Spin, ComCtrls, LazHelpHTML,
  aqblibneural, aqpopulacao, lclintf, Types, Clipbrd;

type

  { TjInicio }

  TjInicio = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    cAbrir: TOpenDialog;
    cArquivo: TEdit;
    cCamadas: TEdit;
    cCiclos: TSpinEdit;
    cEntradas: TCheckListBox;
    cEscala: TFloatSpinEdit;
    cPrio: TComboBox;
    cPara: TButton;
    cProbabilidade: TFloatSpinEdit;
    cSaidas: TCheckListBox;
    ctamanho: TSpinEdit;
    gEntradas: TGroupBox;
    gSaidas: TGroupBox;
    Image1: TImage;
    Label1: TLabel;
    Label10: TLabel;
    l1: TLabel;
    l2: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    PageControl1: TPageControl;
    gEn: TScrollBox;
    gSa: TScrollBox;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    pgAplicar: TTabSheet;
    TabSheet4: TTabSheet;
    cBarra: TTrackBar;
    ToggleBox1: TToggleBox;

    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure DesenhaComponentes();
    procedure cCamadasChange(Sender: TObject);
    procedure CheckGroup1Click(Sender: TObject);
    procedure cParaClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Memo2Change(Sender: TObject);
    procedure MontarColunas;
    procedure cBarraChange(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure TabSheet1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: boolean);
    procedure pgAplicarContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: boolean);
    procedure TabSheet4ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: boolean);
    procedure ToggleBox1Change(Sender: TObject);
  private

  public
    erroglob: double;
    ctLinhas: integer;

    iderroglob: integer;
    //    idmaxerroglob:integer;

    vindiv: tIndiv;

  end;

var
  jInicio: TjInicio;
  dados: array of tcoluna;
  trEntradas, trSaidas: array of tcoluna;    //Calunas Treinamento
  teEntradas, teSaidas: array of tcoluna;    // Coluna Teste

  mcamadas: tcamadaConf1;

  //componentes para os caluculos
  eden: array of tedit;
  edsa: array of tedit;
  txen: array of TStaticText;
  txsa: array of TStaticText;


implementation

{$R *.lfm}

{ TjInicio }


procedure TjInicio.Button1Click(Sender: TObject);
var
  pop: tTreinamento;
begin

  self.MontarColunas;


  if (Length(trEntradas) = 0) or (Length(trSaidas) = 0) or
    (Length(trEntradas[0].valores) = 0) or (Length(trSaidas[0].valores) = 0) then
  begin
    ShowMessage('Falta dados');
    exit;
  end;


  self.Memo1.Clear;
  cpara.Enabled := True;
  self.erroglob := 1e999;



  pop := tTreinamento.Create(trentradas,      //Colunas de entradas
    trsaidas,        //colunas de saida
    ctamanho.Value, //Tamanho de população
    mcamadas,       //Estrutura de camadas
    cciclos.Value  //quantidade de ciclos
    );

end;

procedure TjInicio.Button2Click(Sender: TObject);
var
  textos: TStringArray;
  arquivo: TStringList;
  fi1, fi2: integer;

begin

  if not (cabrir.Execute) then
    exit;
  cArquivo.Text := cabrir.FileName;

  //Abrir arquiv
  arquivo := TStringList.Create();
  arquivo.LoadFromFile(cabrir.FileName);
  ctlinhas := arquivo.Count - 1;


  //Montar barra
  cbarra.Min := 1;
  cbarra.Max := ctlinhas - 1;


  //alocar espaços
  textos := arquivo[0].Split(';');
  setlength(dados, length(textos));
  fi1 := 0;
  while fi1 < length(textos) do
  begin
    setlength(dados[fi1].valores, arquivo.Count - 1);
    Inc(fi1);
  end;

  //Criar colunas de titulos
  textos := arquivo[0].split(';');
  fi2 := 0;
  while fi2 < length(textos) do
  begin
    dados[fi2].Coluna := textos[fi2];
    Inc(fi2);
  end;



  //Criar colunas de dados
  fi1 := 1;
  while fi1 < arquivo.Count do
  begin
    textos := arquivo[fi1].split(';');
    fi2 := 0;
    while fi2 < length(textos) do
    begin
      dados[fi2].valores[fi1 - 1] := strtofloat(textos[fi2]);
      Inc(fi2);
    end;
    Inc(fi1);
  end;

  //adicionar colunas
  cEntradas.Items.Clear;
  cSaidas.Items.Clear;

  fi1 := 0;
  while fi1 < length(dados) do
  begin
    cEntradas.Items.Add(dados[fi1].Coluna);
    cSaidas.Items.Add(dados[fi1].Coluna);
    Inc(fi1);
  end;


  self.cBarraChange(cbarra);

end;

procedure TjInicio.Button3Click(Sender: TObject);
begin
  Memo1.Lines.Add(self.vindiv.CalculaDiferenca(teEntradas, teSaidas));

end;

procedure TjInicio.Button4Click(Sender: TObject);
var
  fentradas: ArrDouble;
  fsaidas: ArrDouble;
  fi: integer;
begin

  //criar variaveis
  SetLength(fentradas, Length(trEntradas));
  fi := 0;
  while fi < Length(trEntradas) do
  begin
    fentradas[fi] := strtofloat(eden[fi].Text);
    Inc(fi);
  end;

  fsaidas := vindiv.CalcularSaidas(fentradas);

  fi := 0;
  while fi < length(trSaidas) do
  begin
    edsa[fi].Text := floattostr(fsaidas[fi]);
    Inc(fi);
  end;

end;

procedure TjInicio.Button5Click(Sender: TObject);
begin
  ShowMessage(n2alfa(1275));
end;

procedure TjInicio.DesenhaComponentes();
var
  fi: integer;

begin
  //Apagar componentes
  fi := 0;
  while fi < length(eden) do
  begin
    eden[fi].Free;
    Inc(fi);
  end;

  fi := 0;
  while fi < length(edsa) do
  begin
    edsa[fi].Free;
    Inc(fi);
  end;

  fi := 0;
  while fi < length(txen) do
  begin
    txen[fi].Free;
    Inc(fi);
  end;

  fi := 0;
  while fi < length(txsa) do
  begin
    txsa[fi].Free;
    Inc(fi);
  end;

  //Desenhar componnses  de entrada
  SetLength(eden, Length(trEntradas));
  SetLength(txen, Length(trEntradas));

  fi := 0;
  fi := length(trEntradas) - 1;
  while fi >= 0 do
  begin

    eden[fi] := TEdit.Create(self);
    with  eden[fi] do
    begin
      Text := '';
      Parent := gEn;
      Align := AlTop;
    end;

    txen[fi] := TStaticText.Create(self);
    with  txen[fi] do
    begin
      Text := '';
      Parent := gEn;
      Align := AlTop;
      Caption := trEntradas[fi].Coluna;
    end;



    Inc(fi, -1);
  end;

  //Desenhar componnses  de saida
  SetLength(edsa, Length(trsaidas));
  SetLength(txsa, Length(trsaidas));
  fi := 0;
  fi := length(trsaidas) - 1;
  while fi >= 0 do
  begin

    edsa[fi] := TEdit.Create(self);
    with  edsa[fi] do
    begin
      Text := '';
      Parent := gsa;
      Align := AlTop;
    end;


    txsa[fi] := TStaticText.Create(self);
    with  txsa[fi] do
    begin
      Text := '';
      Parent := gSa;
      Align := AlTop;
      Caption := trsaidas[fi].Coluna;
    end;



    Inc(fi, -1);
  end;

end;

procedure TjInicio.cCamadasChange(Sender: TObject);
var
  temp: TStringArray;
  temp1, numero, tx: string;
  letra: char;
  fi, fi1: integer;

begin

  setlength(mcamadas.tccf, 0);
  temp1 := ccamadas.Text;
  temp := temp1.Split(';');

  fi := 0;
  while fi < length(temp) do
  begin
    try
      tx := temp[fi];
      fi1 := StrToInt(Copy(tx, 1, length(tx) - 1));
      letra := tx[length(tx)];

      setlength(mcamadas.tccf, length(mcamadas.tccf) + 1);
      mcamadas.tccf[length(mcamadas.tccf) - 1].neuronios := fi1;
      mcamadas.tccf[length(mcamadas.tccf) - 1].funcao := letra;

    except
    end;
    Inc(fi);
  end;

end;

procedure TjInicio.CheckGroup1Click(Sender: TObject);
begin

end;

procedure TjInicio.cParaClick(Sender: TObject);
begin
  cpara.Enabled := False;
end;

procedure TjInicio.FormCreate(Sender: TObject);
begin

end;

procedure TjInicio.FormShow(Sender: TObject);
begin
  self.cCamadasChange(self.cCamadas);
  PageControl1.ActivePageIndex := 0;
end;

procedure TjInicio.Image1Click(Sender: TObject);
begin
  OpenURL('http://www.atta.eng.br/#Atta_Neural');
end;

procedure TjInicio.Memo2Change(Sender: TObject);
begin

end;

procedure TjInicio.MontarColunas;
var
  fi, fial: integer;
  ctTr, ctTe, frand: integer;
  fi1, fi2: integer;

begin

  cttr := cbarra.Position;
  ctte := ctLinhas - cttr;

  setlength(trEntradas, 0);
  setlength(trSaidas, 0);
  setlength(teEntradas, 0);
  setlength(teSaidas, 0);



  fi := 0;
  while fi < length(dados) do
  begin

    if cEntradas.Checked[fi] then
    begin
      setlength(trentradas, length(trEntradas) + 1);
      setlength(teentradas, length(teEntradas) + 1);

      trEntradas[length(trEntradas) - 1].Coluna := dados[fi].Coluna;
      trEntradas[length(trEntradas) - 1].idColunaDados := fi;

      teEntradas[length(teEntradas) - 1].Coluna := dados[fi].Coluna;
      teEntradas[length(teEntradas) - 1].idColunaDados := fi;

      SetLength(trEntradas[length(trEntradas) - 1].valores, cttr);
      SetLength(teEntradas[length(teEntradas) - 1].valores, ctte);

    end;

    if cSaidas.Checked[fi] then
    begin
      setlength(trSaidas, length(trSaidas) + 1);
      setlength(teSaidas, length(teSaidas) + 1);

      trSaidas[length(trSaidas) - 1].Coluna := dados[fi].Coluna;
      trSaidas[length(trSaidas) - 1].idColunaDados := fi;

      teSaidas[length(teSaidas) - 1].Coluna := dados[fi].Coluna;
      teSaidas[length(teSaidas) - 1].idColunaDados := fi;

      SetLength(trSaidas[length(trSaidas) - 1].valores, cttr);
      SetLength(teSaidas[length(teSaidas) - 1].valores, ctte);

    end;

    Inc(fi);
  end;


  fi := 0;
  fial := 0;

  fi := length(dados[0].valores) - 1;
  while fi >= 0 do
  begin

    if fial < cbarra.Position then
    begin
      Inc(ctTr, -1);

      fi2 := 0;
      while fi2 < length(trEntradas) do
      begin
        trEntradas[fi2].valores[cttr] :=
          dados[trEntradas[fi2].idColunaDados].valores[fi];
        Inc(fi2);
      end;

      fi2 := 0;
      while fi2 < length(trsaidas) do
      begin
        trsaidas[fi2].valores[cttr] :=
          dados[trsaidas[fi2].idColunaDados].valores[fi];
        Inc(fi2);
      end;

    end
    else
    begin
      Inc(ctTe, -1);
      fi2 := 0;
      while fi2 < length(teEntradas) do
      begin
        teEntradas[fi2].valores[ctte] :=
          dados[teEntradas[fi2].idColunaDados].valores[fi];
        Inc(fi2);
      end;

      fi2 := 0;
      while fi2 < length(tesaidas) do
      begin
        tesaidas[fi2].valores[ctte] :=
          dados[tesaidas[fi2].idColunaDados].valores[fi];
        Inc(fi2);
      end;

    end;

    Inc(fi, -1);
    fial := (fial + primo) mod length(dados[0].valores);

  end;

end;

procedure TjInicio.cBarraChange(Sender: TObject);
begin
  l1.Caption := IntToStr(cBarra.Position) + ' (' +
    formatfloat('0.0', (cbarra.Position * 100.0) / (ctlinhas)) + '%)';

  l2.Caption := IntToStr(-cBarra.Position + ctlinhas) + ' (' +
    formatfloat('0.0', ((-cBarra.Position + ctlinhas) * 100.0) / (ctlinhas)) + '%)';

end;

procedure TjInicio.PageControl1Change(Sender: TObject);
begin
  if PageControl1.ActivePage.Name = pgAplicar.Name then
  begin
    self.DesenhaComponentes();
  end;
end;

procedure TjInicio.TabSheet1ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: boolean);
begin

end;

procedure TjInicio.pgAplicarContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: boolean);
begin

end;

procedure TjInicio.TabSheet4ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: boolean);
begin

end;

procedure TjInicio.ToggleBox1Change(Sender: TObject);
begin
  Clipboard.AsText := vindiv.SalvarPesosTab();
  ShowMessage('Cole na célula A1 de sua planilha!');
end;

end.















