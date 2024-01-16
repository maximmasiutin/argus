
var
  FormStrList: TStringList;
  AuxFormStrList: TStringList;
  IncStrList: TStringList;
  FormLngIndex: Integer;
  MaxLen: Integer;

function LongListD(L: TStrings): string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to L.Count-2 do Result := Result + L[i] + '|';
  for i := MaxI(0, L.Count-1) to L.Count-1 do Result := Result + L[i];
end;

type
  TMyControl = class(TControl);

procedure GrabForm(F: TForm{; const FName: String});

var
  zz: string;

procedure AddComponent(C: TComponent);


procedure Add(const z: string);
var
  v, cn: string;
begin
  cn := C.Name;

  if F is TMailerForm then
  begin
    if (cn = 'ompPoll') or
       (cn = 'ompAttach') or
       (cn = 'ompEditFreq') or
       (cn = 'ompBrowseNL') or
       (cn = 'ompCreateFlag') or
       (cn = 'ompOpen') or
       (cn = 'ompCur') or
       (cn = 'ompName') or
       (cn = 'ompExt') or
       (cn = 'ompStat') or
       (cn = 'ompAll') or
       (cn = 'ompEntire') then Exit;
  end;

  v := z;
  Replace('|', #13#10, v);
  AuxFormStrList.Add(v);

  v := #9'"'+cn+'|'+z+'\n"\'#13#10;
  zz := zz + v;
end;


var
  D: TMyControl;
  L: TListView;
  P: TPageControl;
  H: THeaderControl;
  M: TMenuItem;
  s: string;
  i: Integer;
begin
  D := nil;
  if C is TControl then D := TMyControl(C);
  if C is
TMenuItem then
  begin
    M := C as TMenuItem;
    if M.Caption <> '-' then Add(M.Caption)
  end else if C is
TLabel then
  begin
    if D.Caption <> '' then Add(D.Caption)
  end else if C is
TButton then
  begin
    Add(D.Caption)
  end else if C is
TCheckBox then
  begin
    if D.Caption <> '' then Add(D.Caption)
  end else if C is
TRadioButton then
  begin
    Add(D.Caption)
  end else if C is
TGroupBox then
  begin
    Add(D.Caption)
  end else if C is
TRadioGroup then
  begin
    Add(D.Caption+'|'+LongListD(TRadioGroup(C).Items))
  end else if C is
TPanel then
  begin
    if D.Caption <> '' then Add(D.Caption)
  end else if C is
TPageControl then
  begin
    P := C as TPageControl;
    s := '';
    for i := 0 to P.PageCount-1 do s := s + '|'+P.Pages[i].Caption;
    DelFc(s);
    Add(s)
  end else if C is
TListView then
  begin
    L := C as TListView;
    s := '';
    for i := 0 to L.Columns.Count-1 do s := s + '|' + L.Columns[i].Caption;
    DelFc(s);
    Add(s);
  end else if C is
THeaderControl then
  begin
    H := C as THeaderControl;
    s := '';
    for i := 0 to H.Sections.Count-1 do s := s + '|' + H.Sections[i].Text;
    DelFc(s); 
    Add(s);
  end;
end;

var
  i: Integer;
  ConstName: string;
begin
  if FormLngIndex = 0 then FormLngIndex := 10;
  if FormStrList = nil then FormStrList := TStringList.Create;
  if AuxFormStrList = nil then AuxFormStrList := TStringList.Create;
  if IncStrList = nil then IncStrList := TStringList.Create;
  zz := '';
  for I := 0 to F.ComponentCount-1 do AddComponent(F.Components[I]);
  SetLength(zz, Length(zz)-3);
  MaxLen := MaxI(MaxLen, Length(zz));
  ConstName := 'rs'+F.Name;
  FormStrList.Add(' LngBaseEnglish+'+ConstName+' "'+F.Caption+'\n"\'#13#10+zz+#13#10);
  AuxFormStrList.Add(F.Caption);
  IncStrList.Add(#9+ConstName+StringOfChar(' ', 20-Length(ConstName))+ ' = '+IntToStr(FormLngIndex)+';');
  Inc(FormLngIndex);
end;

procedure StoreGrabbed;
begin
  FormStrList.Insert(0, 'STRINGTABLE'#13#10+'{'#13#10);
  FormStrList.Add('}');
  FormStrList.SaveToFile('d:\aaa.txt');
  AuxFormStrList.SaveToFile('d:\bbb.txt');
  IncStrList.Insert(0, 'const');
  IncStrList.SaveToFile('d:\ccc.txt');
end;
