{
  DM CSV A CSV Class for Delphi
  By Ben Jones 26/8/2015

  If you have any questions you can email me at:
  Email: dreamvb@outlook.com
  Enjoy the class

  Updated 19:58 12/10/2015
  //Added remove quotes from field return property.
}

unit dmcsv;

interface

uses
  SysUtils, Variants, Classes, Dialogs;

type TCsv = class
  private
    m_Filename: string;
    m_Delimiter: Char;
    m_Quotes : Boolean;
    DBRecord: TStringList;
    DBFields: TStringList;
    function RCount: Integer;
    function FCount: Integer;

    procedure QStrSet(n : Boolean);
    function QStrGet : Boolean;

    function BuildRecord(Vals: TStringList): string;
  public
    constructor Create(Filename: string; Delimiter: Char);
    destructor Destroy; override;
    property FileName: string read m_Filename;
    property RecordCount: Integer read RCount;
    property FieldCount: Integer read FCount;
    property RemoveQuotes : Boolean read QStrGet write QStrSet;
    function GetFieldVal(Rec: Integer; Field: Integer): string;
    function GetFieldName(Index: Integer): string;
    function toString: string;
    procedure SetFieldName(Index: Integer; vName: string);
    procedure SetFieldVal(Rec: Integer; Field: Integer; vData: string);

    procedure AddFields(Items: TStringList);
    procedure AddRecord(Items: TStringList);
    procedure Update;
    procedure RemoveRecord(Index: Integer);
    procedure RemoveField(Index: Integer);
    procedure ClearRecords;

  end;

function MySplitStr(src: string; sep: char): TStringList;

implementation

destructor TCsv.Destroy;
begin
  //Clear up used objects.
  DBRecord.Free;
  DBFields.Free;
end;

constructor TCsv.Create(Filename: string; Delimiter: Char);
var
  tmp: TStringList;
  Lst: TStringList;
  I: Integer;
  RecData: string;
begin
  //Set filename
  m_Filename := Filename;
  //Delimiter split char.
  m_Delimiter := Delimiter;
  //Create records list.
  //Keep default return quotes on.
  m_Quotes := False;
  DBRecord := TStringList.Create;
  //Create temp list
  Tmp := TStringList.Create;
  //Create fields list.
  DBFields := TStringList.Create;
  Lst := TStringList.Create;
  //Check if the file is found.
  if FileExists(Filename) then
  begin
    try
    //Load file into string list.
      Tmp.LoadFromFile(Filename);
    except
      on E: Exception do
        raise e.Create(E.Message);
    end;

    if Tmp.Count > 0 then
    begin
      //Grab first row.
      Lst := MySplitStr(Tmp[0], m_Delimiter);

      //Add to filds.
      for I := 0 to lst.Count - 1 do
      begin
        //Add field
        DBFields.Add(lst[I])
      end;

      if tmp.Count > 0 then
      begin
        //Copy records to _data
        for I := 1 to tmp.Count - 1 do
        begin
          //Get record.
          RecData := tmp[I];
          //Check record length.
          if Length(RecData) > 0 then
            //Add strings to records string list.
            DBRecord.Add(tmp[I])
        end;
      end;
    end;
    //Clear up.
    RecData := '';
    lst.Free;
    Tmp.Free;
  end;
end;

procedure TCsv.AddRecord(Items: TStringList);
begin

  if Items.Count <> FieldCount then
  begin
    raise Exception.Create('Index out of range');
    Exit;
  end;

  //Add to the records.
  DBRecord.Add(BuildRecord(Items))
end;

procedure TCsv.AddFields(Items: TStringList);
var
  I: Integer;
begin
  //Clear eveything.
  DBFields.Clear;

  //Add field names.
  for I := 0 to Items.Count - 1 do
  begin
    //Add field names.
    DBFields.Add(Items[I]);
  end;
end;

procedure TCsv.RemoveRecord(Index: Integer);
begin
  //Check index.
  if (Index < 0) or (Index > RecordCount) then
  begin
    raise Exception.Create('Index out of range');
    Exit;
  end;
  //Delete the record.
  DBRecord.Delete(Index);
end;

procedure TCsv.RemoveField(Index: Integer);
var
  I: Integer;
  TmpLst: TStringList;
  TmpRecs: TStringList;
begin

  //Check index.
  if (Index < 0) or (Index > FieldCount) then
  begin
    raise Exception.Create('Index out of range');
    Exit;
  end;

  //Create the string lists.
  TmpLst := TStringList.Create;
  TmpRecs := TStringList.Create;

  for I := 0 to DBFields.Count - 1 do
  begin
    TmpLst.Add(DBFields[I]);
  end;

  //Delete the field.
  TmpLst.Delete(Index);
  //Clear fields.
  DBFields.Clear;

  //Add new fields.
  for I := 0 to TmpLst.Count - 1 do
  begin
    DBFields.Add(TmpLst[I]);
  end;

  //Clear temp list.
  TmpLst.Clear;

  //Fix records.
  for I := 0 to DBRecord.Count - 1 do
  begin
    TmpLst := MySplitStr(DBRecord[I], m_Delimiter);
    TmpLst.Delete(Index);
    TmpRecs.Add(BuildRecord(TmpLst))
  end;

  //Clear all records.
  DBRecord.Clear;

  for I := 0 to TmpRecs.Count - 1 do
  begin
    DBRecord.Add(TmpRecs[I]);
  end;

  //Clear up.
  TmpLst.Free;
  TmpRecs.Free;

end;

function TCsv.FCount: Integer;
begin
  //Read the first item in _data
  FCount := DBFields.Count;
end;

function TCsv.RCount: Integer;
begin
  //Return record count.
  Result := DBRecord.Count;
end;

procedure TCsv.QStrSet(n: Boolean);
begin
  m_Quotes := n;
end;

function Tcsv.QStrGet : Boolean;
begin
  Result := m_Quotes;
end;

function TCsv.GetFieldVal(Rec: Integer; Field: Integer): string;
var
  lst: TStringList;
begin

  if FieldCount = 0 then Exit;

  if (Rec < 0) or (Rec > RecordCount) then
  begin
    raise Exception.Create('Index out of range');
    Exit;
  end;
  if (Field < 0) or (Field > FieldCount) then
  begin
    raise Exception.Create('Index out of range');
    Exit;
  end;

  //Split the string.
  lst := MySplitStr(DBRecord[Rec], m_Delimiter);

  if lst.Count > 0 then
  begin
    if RemoveQuotes then
    begin
      //Remove the quotes from a string.
      Result := StringReplace(lst[Field],'"','',[rfReplaceAll]);
    end
    else
    begin
      //Return quoted string.
      Result := lst[Field];
    end;
    lst.Free;
  end;
end;

procedure TCsv.SetFieldName(Index: Integer; vName: string);
begin
  if (Index < 0) or (Index > FieldCount) then
  begin
    raise Exception.Create('Index out of range');
    Exit;
  end;
  //Set the field name.
  DBFields[Index] := vName;
end;

function TCsv.GetFieldName(Index: Integer): string;
begin
  if (Index < 0) or (Index > FieldCount) then
  begin
    raise Exception.Create('Index out of range');
    Exit;
  end;
  //Set the field name.
  Result := DBFields[Index];
end;

procedure TCsv.SetFieldVal(Rec: Integer; Field: Integer; vData: string);
var
  lst: TStringList;
  sFieldBuffer: string;
begin

  if FieldCount = 0 then Exit;

  if (Rec < 0) or (Rec > RecordCount) then
  begin
    raise Exception.Create('Index out of range');
    Exit;
  end;
  if (Field < 0) or (Field > FieldCount) then
  begin
    raise Exception.Create('Index out of range');
    Exit;
  end;

  //Split the string.
  lst := MySplitStr(DBRecord[Rec], m_Delimiter);

  if lst.Count > 0 then
  begin
    //Result := lst[Field];
    lst[Field] := vData;
    //Build record.
    sFieldBuffer := BuildRecord(lst);
    //Update the record.
    DBRecord[Rec] := sFieldBuffer;
    //Clear up.
    sFieldBuffer := '';
    lst.Free;
  end;
end;

procedure TCsv.ClearRecords;
begin
  DBRecord.Clear;
end;

procedure TCsv.Update;
var
  fp: TextFile;
begin
  //Save to the file.
  try
    AssignFile(fp, FileName);
    ReWrite(fp);
    Write(fp, toString);
    CloseFile(fp);
  except
    on E: Exception do
      raise e.Create(E.Message);
  end;
end;

function TCsv.toString: string;
var
  Recs: TStringList;
  I: Integer;
begin
  //Build raw data of csv.
  Recs := TStringList.Create;
   //First add field names.
  Recs.Add(BuildRecord(DBFields));
   //Add the records.
  for I := 0 to DBRecord.Count - 1 do
  begin
    //Add record.
    Recs.Add(DBRecord[I]);
  end;
  Result := Recs.Text;
  Recs.Free;
end;

//Tools.

function TCsv.BuildRecord(Vals: TStringList): string;
var
  I: Integer;
  Ret: string;
begin
  for I := 0 to Vals.Count - 1 do
  begin
    Ret := Ret + Vals[I] + m_Delimiter;
  end;
  Delete(Ret, Length(Ret), 1);
  Result := Ret;
end;

function MySplitStr(src: string; sep: char): TStringList;
var
  ts: TStringList;
  I: Integer;
  J: Integer;
  sLen: Integer;
  sTemp: string;
  Buffer: string;
  Ret: string;
  C: string;

begin
  ts := TStringList.Create;

  sTemp := src;
  sLen := Length(sTemp);

  if sLen > 0 then
  begin
    if sTemp[sLen] <> sep then
    begin
      sTemp := sTemp + sep;
      //Set new length.
      sLen := Length(sTemp) + 1;
    end;
  end;
  //Set start counter.
  I := 1;

  while I < sLen do
  begin
      //Get char.
    C := sTemp[I];

    //Check for quotes.
    if C = '"' then
    begin
      //Find next quote and build output string.
      for J := I + 1 to sLen do
      begin
        //Check for quote
        if sTemp[J] = '"' then
        begin
          //Clear current char and exit loop
          C := '';
          break;
        end;
        //Build the soure string
        Ret := Ret + sTemp[J];
      end;
      //Add to collection.
      ts.Add('"' + Ret + '"');
      //Clear up
      Ret := '';
      //Move I to new position.
      I := J + 1;
    end;

    //Check for seperator.
    if C <> sep then
    begin
      //Build output string
      Buffer := Buffer + C;
    end
    else
    begin
      //Add to collection.
      ts.Add(Buffer);
      //Clear up.
      Buffer := '';
    end;
    //INC Counter.
    INC(I);
  end;
  //Return strings.
  MySplitStr := ts;
  //Clear up.
  sTemp := '';
end;
end.
