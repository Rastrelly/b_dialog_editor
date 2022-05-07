unit udialogeditor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ComCtrls,
  ExtCtrls, StdCtrls;

type

  { TForm1 }

  uline = record
    tdir,text:string;
    strreq,agireq,spdreq,intreq:integer;
    perkreq:array of integer;
    flagreq:array of integer;
  end;

  TNode = class
    public
        nodeid,nodetext,portid:string;
        canleave:boolean;
        actul,actperk,actflag:integer;

        ulines:array of uline;

        procedure addul;
        procedure remul;
        procedure moveul(dir:integer);

        procedure addperk(id:integer);
        procedure remperk;

        procedure addflag(id:integer);
        procedure remflag;

        constructor Create;
  end;

  TForm1 = class(TForm)
    bAddLine: TButton;
    bRemLine: TButton;
    bUpLine: TButton;
    bDownLine: TButton;
    bUpdateLine: TButton;
    bSaveNode: TButton;
    bAddPerkReq: TButton;
    bRemPerkReq: TButton;
    bAddFlagReq: TButton;
    bRemFlagReq: TButton;
    bLoadNode: TButton;
    bRefreshFileList: TButton;
    bOpenFileFromList: TButton;
    cbCanLeave: TCheckBox;
    edNodeId: TEdit;
    edPortId: TEdit;
    edTargetNode: TEdit;
    edStrReq: TEdit;
    edAgiReq: TEdit;
    edSpdReq: TEdit;
    edIntReq: TEdit;
    edPerkNo: TEdit;
    edFlagNo: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    lFileName: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lbULines: TListBox;
    lbPerkList: TListBox;
    lbFlagList: TListBox;
    lbFiles: TListBox;
    MainMenu1: TMainMenu;
    memoFilePreview: TMemo;
    memoNodeText: TMemo;
    memoULine: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    miSave: TMenuItem;
    miOpen: TMenuItem;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel12: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    StatusBar1: TStatusBar;
    procedure bOpenFileFromListClick(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure RefreshFileList;
    procedure GetFileList;
    procedure bLoadNodeClick(Sender: TObject);
    procedure bRefreshFileListClick(Sender: TObject);
    procedure lbFilesClick(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure FillNodeDataFromUi;
    procedure SaveCurrentNode;
    procedure UpdateLine;
    procedure OpenNode(fn:string);
    procedure bAddFlagReqClick(Sender: TObject);
    procedure bAddPerkReqClick(Sender: TObject);
    procedure bRemFlagReqClick(Sender: TObject);
    procedure bRemPerkReqClick(Sender: TObject);
    procedure bSaveNodeClick(Sender: TObject);
    procedure bUpdateLineClick(Sender: TObject);
    procedure lbFlagListClick(Sender: TObject);
    procedure lbPerkListClick(Sender: TObject);
    procedure UpdateUI;
    procedure bAddLineClick(Sender: TObject);
    procedure bDownLineClick(Sender: TObject);
    procedure bRemLineClick(Sender: TObject);
    procedure bUpLineClick(Sender: TObject);
    procedure lbULinesClick(Sender: TObject);
    procedure SaveSettings;
    procedure LoadSettings;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure SetWorkFolder(folder:string);
    procedure miOpenClick(Sender: TObject);
    procedure miSaveClick(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

  //globals
  appfolder:string;
  workfolder:string;
  settings:TextFile;
  nodefile:TextFile;

  foundfiles:array of string;

  cnode:TNode;


implementation

{$R *.lfm}

{ TForm1 }

constructor TNode.Create;
begin
  //
end;

procedure TNode.addul;
begin
  setlength(ulines,Length(ulines)+1);
end;

procedure TNode.remul;
var i,ull,al:integer;
begin
  al:=actul;
  ull:=Length(ulines);
  if (al<ull-1) then
  begin
    for i:=al to ull-2 do
    begin
      ulines[i]:=ulines[i+1];
    end;
  end;
  setlength(ulines,ull-1);
  if (actul>Length(ulines)-1) then actul:=length(ulines)-1;
end;

procedure TNode.moveul(dir:integer);
var a,b,i,ull,al:integer;
    cul:uline;
begin

  ull:=Length(ulines);

  al:=actul;

  a:=al;
  b:=al+dir;

  if (b>=0) and (b<ull) then
  begin
    cul:=ulines[a];
    ulines[a]:=ulines[b];
    ulines[b]:=cul;
  end;

end;

procedure TNode.addperk(id:integer);
begin
  setlength(ulines[actul].perkreq,length(ulines[actul].perkreq)+1);
  ulines[actul].perkreq[high(ulines[actul].perkreq)]:=id;
end;

procedure TNode.remperk;
var i,ull,pll,al,ap:integer;
begin
  al:=actul;
  ap:=actperk;
  ull:=Length(ulines);
  if (al<ull-1) then
  begin

    pll:=Length(ulines[al].perkreq);

    for i:=ap to pll-2 do
    begin
      ulines[al].perkreq[i]:=ulines[al].perkreq[i+1];
    end;
  end;
  setlength(ulines[al].perkreq,pll-1);

  if (actperk>Length(ulines[al].perkreq)-1) then
     actperk:=length(ulines[al].perkreq)-1;

end;

procedure TNode.addflag(id:integer);
begin
  setlength(ulines[actul].flagreq,length(ulines[actul].flagreq)+1);
  ulines[actul].flagreq[high(ulines[actul].flagreq)]:=id;
end;

procedure TNode.remflag;
var i,ull,fll,al,af:integer;
begin
  al:=actul;
  af:=actflag;
  ull:=Length(ulines);
  if (al<ull-1) then
  begin

    fll:=Length(ulines[al].flagreq);

    for i:=af to fll-2 do
    begin
      ulines[al].flagreq[i]:=ulines[al].flagreq[i+1];
    end;
  end;
  setlength(ulines[al].flagreq,fll-1);

  if (actflag>Length(ulines[al].flagreq)-1) then
     actflag:=length(ulines[al].flagreq)-1;

end;

procedure TForm1.GetFileList;
var Info : TSearchRec;
begin
  //fetches list of .nod files from workfolder
  setlength(foundfiles,0);

  if FindFirst(workfolder + '\*.nod', faAnyFile and faDirectory, Info)=0 then begin
     repeat
       setlength(foundfiles,length(foundfiles)+1);
       foundfiles[high(foundfiles)]:=Info.Name;
     until FindNext(Info) <> 0;
  end;
  FindClose(Info);
end;

procedure TForm1.FillNodeDataFromUi;
begin
    with cnode do
    begin
      nodeid:=edNodeId.Text;
      portid:=edPortId.Text;
      nodetext:=memoNodeText.Text;
      canleave:=cbCanLeave.Checked;
    end;
    UpdateUI;
end;

procedure TForm1.SaveCurrentNode;
var fn:string;
    l,pl,fl,i,j:integer;
begin

  FillNodeDataFromUi;

  fn:=workfolder+'\'+cnode.nodeid+'.nod';

  AssignFile(nodefile,fn);
  Rewrite(nodefile);

  with cnode do
  begin
    WriteLn(nodefile,nodeid);
    WriteLn(nodefile,nodetext);
    WriteLn(nodefile,portid);
    WriteLn(nodefile,booltostr(canleave));

    l:=Length(ulines);
    WriteLn(nodefile,inttostr(l));

    if (l>0) then
    for i:=0 to l-1 do
    begin
      //writing ulines
      {  uline = record
          tdir,text:string;
          strreq,agireq,spdreq,intreq:integer;
          perkreq:array of integer;
          flagreq:array of integer;
         end; }
      WriteLn(nodefile,ulines[i].tdir);
      WriteLn(nodefile,ulines[i].text);
      WriteLn(nodefile,inttostr(ulines[i].strreq));
      WriteLn(nodefile,inttostr(ulines[i].agireq));
      WriteLn(nodefile,inttostr(ulines[i].spdreq));
      WriteLn(nodefile,inttostr(ulines[i].intreq));
      //now recording perks and flags by the same principle
      //perks
      pl:=Length(ulines[i].perkreq);
      WriteLn(nodefile,inttostr(pl));
      if (pl>0) then
      for j:=0 to pl-1 do
      begin
        WriteLn(nodefile,inttostr(ulines[i].perkreq[j]));
      end;
      //flags
      fl:=Length(ulines[i].perkreq);
      WriteLn(nodefile,inttostr(fl));
      if (fl>0) then
      for j:=0 to fl-1 do
      begin
        WriteLn(nodefile,inttostr(ulines[i].flagreq[j]));
      end;
    end;

  end;

  closefile(nodefile);

  RefreshFileList;

end;

procedure TForm1.MenuItem2Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
     OpenNode(OpenDialog1.FileName);
  end;
end;

procedure TForm1.bLoadNodeClick(Sender: TObject);
begin
  OpenNode(workfolder+'\'+edNodeId.Text+'.nod');
end;

procedure TForm1.RefreshFileList;
var i,l:integer;
begin
  GetFileList;
  lbFiles.Clear;
  l:=Length(foundfiles);
  if l>0 then
  begin
    for i:=0 to l-1 do lbFiles.AddItem(foundfiles[i],lbFiles);
  end;
end;

procedure TForm1.bOpenFileFromListClick(Sender: TObject);
begin
  if (lbFiles.ItemIndex>=0) then
  OpenNode(workfolder+'\'+lbFiles.Items[lbFiles.ItemIndex]);
end;

procedure TForm1.MenuItem3Click(Sender: TObject);
begin
  Form1.Close;
end;

procedure TForm1.bRefreshFileListClick(Sender: TObject);
begin
  RefreshFileList;
end;

procedure TForm1.lbFilesClick(Sender: TObject);
begin
  if (lbFiles.Count>0) and (lbFiles.ItemIndex>=0) then
  begin
  lFileName.Caption:='File Name: '+lbFiles.Items[lbFiles.ItemIndex];
  memoFilePreview.Lines.LoadFromFile(workfolder+'\'+lbFiles.Items[lbFiles.ItemIndex]);
  end;
end;


procedure TForm1.OpenNode(fn:string);
var l,pl,fl,i,j:integer;
    ts:string;
begin
  if FileExists(fn) then
  begin

    AssignFile(nodefile,fn);
    Reset(nodefile);

    with (cnode) do
    begin
         ReadLn(nodefile,nodeid);
         ReadLn(nodefile,nodetext);
         ReadLn(nodefile,portid);
         ReadLn(nodefile,ts);
         canleave:=strtobool(ts);
         ReadLn(nodefile,ts);
         l:=strtoint(ts);
         setlength(ulines,l);
         if (l>0) then
         for i:=0 to l-1 do
         begin
           //reading ulines
           ReadLn(nodefile,ulines[i].tdir);
           ReadLn(nodefile,ulines[i].text);
           ReadLn(nodefile,ts);
           ulines[i].strreq:=strtoint(ts);
           ReadLn(nodefile,ts);
           ulines[i].agireq:=strtoint(ts);
           ReadLn(nodefile,ts);
           ulines[i].spdreq:=strtoint(ts);
           ReadLn(nodefile,ts);
           ulines[i].intreq:=strtoint(ts);
           ReadLn(nodefile,ts);
           pl:=strtoint(ts);
           SetLength(ulines[i].perkreq,pl);
           if (pl>0) then
           for j:=0 to pl-1 do
           begin
             ReadLn(nodefile,ts);
             ulines[i].perkreq[j]:=strtoint(ts);
           end;
           ReadLn(nodefile,ts);
           fl:=strtoint(ts);
           SetLength(ulines[i].flagreq,pl);
           if (pl>0) then
           for j:=0 to fl-1 do
           begin
             ReadLn(nodefile,ts);
             ulines[i].flagreq[j]:=strtoint(ts);
           end;
         end;
    end;

    CloseFile(nodefile);

    UpdateUI;

  end;
end;

procedure Tform1.UpdateUI;
var i,ull,pl,fl:integer;
begin

  //basic cnode data
  edNodeId.Text:=cnode.nodeid;
  edPortId.Text:=cnode.portid;
  memoNodeText.Text:=cnode.nodetext;
  cbCanLeave.Checked:=cnode.canleave;

  //user line list
  ull:=length(cnode.ulines);
  lbULines.Clear;
  if (ull>0) then
  for i:=0 to ull-1 do
  begin
    lbULines.AddItem(cnode.ulines[i].text,lbULines);
  end;

  //user line data
  if (ull>0) then
  begin
    memoULine.Text:=cnode.ulines[cnode.actul].text;
    edTargetNode.Text:=cnode.ulines[cnode.actul].tdir;
    edStrReq.Text:=inttostr(cnode.ulines[cnode.actul].strreq);
    edAgiReq.Text:=inttostr(cnode.ulines[cnode.actul].agireq);
    edSpdReq.Text:=inttostr(cnode.ulines[cnode.actul].spdreq);
    edIntReq.Text:=inttostr(cnode.ulines[cnode.actul].intreq);
  end;

  if (ull>0) and (cnode.actul<ull) then
  lbULines.ItemIndex:=cnode.actul;

  //perks and flags
  lbPerkList.Clear;
  lbFlagList.Clear;
  if (ull>0) then
  begin
    pl:=length(cnode.ulines[cnode.actul].perkreq);
    for i:=0 to pl-1 do
      lbPerkList.AddItem(inttostr(cnode.ulines[cnode.actul].perkreq[i]),
                         lbPerkList);
    fl:=length(cnode.ulines[cnode.actul].flagreq);
    for i:=0 to fl-1 do
      lbFlagList.AddItem(inttostr(cnode.ulines[cnode.actul].flagreq[i]),
                         lbFlagList);

  end;

  //file list data
  RefreshFileList;
end;

procedure TForm1.UpdateLine;
begin
  if (length(cnode.ulines)>0) then
  begin
    with cnode.ulines[cnode.actul] do
    begin
      text:=memoULine.Text;
      tdir:=edTargetNode.Text;
      strreq:=strtoint(edStrReq.Text);
      agireq:=strtoint(edAgiReq.Text);
      spdreq:=strtoint(edSpdReq.Text);
      intreq:=strtoint(edIntReq.Text);
    end;

    UpdateUI;
  end;
end;

procedure TForm1.bUpdateLineClick(Sender: TObject);
begin
  UpdateLine;
end;

procedure TForm1.bAddPerkReqClick(Sender: TObject);
begin
  cnode.addperk(strtoint(edPerkNo.Text));
  UpdateLine;
  UpdateUI;
end;

procedure TForm1.bRemFlagReqClick(Sender: TObject);
begin
  cnode.remflag;
  UpdateLine;
  UpdateUI;
end;

procedure TForm1.bRemPerkReqClick(Sender: TObject);
begin
  cnode.remperk;
  UpdateLine;
  UpdateUI;
end;

procedure TForm1.bSaveNodeClick(Sender: TObject);
begin
  SaveCurrentNode;
end;

procedure TForm1.bAddFlagReqClick(Sender: TObject);
begin
  cnode.addflag(strtoint(edFlagNo.Text));
  UpdateLine;
  UpdateUI;
end;

procedure TForm1.lbFlagListClick(Sender: TObject);
begin
  cnode.actflag:=lbFlagList.ItemIndex;
end;

procedure TForm1.lbPerkListClick(Sender: TObject);
begin
  cnode.actperk:=lbPerkList.ItemIndex;
end;

procedure TForm1.LoadSettings;
var fn,wf:string;
begin
  fn:=appfolder+'settings.cfg';
  if FileExists(fn) then
  begin
    AssignFile(settings,fn);
    reset(settings);
    ReadLn(settings,wf);
    SetWorkFolder(wf);
    closefile(settings);
  end;
end;

procedure TForm1.SaveSettings;
var fn:string;
begin
  fn:=appfolder+'settings.cfg';
  AssignFile(settings,fn);
  Rewrite(settings);
  WriteLn(settings,workfolder);
  CloseFile(settings);
end;

procedure TForm1.bAddLineClick(Sender: TObject);
begin
  cnode.addul;
  UpdateUI;
end;

procedure TForm1.bDownLineClick(Sender: TObject);
begin
  cnode.moveul(1);
    UpdateUI;
end;

procedure TForm1.bRemLineClick(Sender: TObject);
begin
  cnode.remul;
    UpdateUI;
end;

procedure TForm1.bUpLineClick(Sender: TObject);
begin
  cnode.moveul(-1);
    UpdateUI;
end;

procedure TForm1.lbULinesClick(Sender: TObject);
begin
  if lbULines.ItemIndex<>-1 then cnode.actul:=lbULines.ItemIndex else cnode.actul:=0;
  UpdateUI;
end;

procedure TForm1.SetWorkFolder(folder:string);
begin
  workfolder:=folder;
  StatusBar1.Panels[0].Text:=folder;
  OpenDialog1.InitialDir:=folder;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  appfolder:=ExtractFileDir(Application.ExeName)+'\';
  StatusBar1.Panels[1].Text:=appfolder;
  LoadSettings;
  cnode:=TNode.Create;
  RefreshFileList;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (MessageDlg('Confirm','Are you sure you want to quit?',mtConfirmation,mbOKCancel,0,mbOk)=mrOK) then
  begin
    SaveSettings;
    Application.Terminate;
  end;
end;

procedure TForm1.miSaveClick(Sender: TObject);
begin
  bSaveNode.Click;
end;

procedure TForm1.miOpenClick(Sender: TObject);
begin
  if (SelectDirectoryDialog1.Execute) then
  begin
    SetWorkFolder(SelectDirectoryDialog1.FileName);
    SaveSettings;
  end;
end;

end.

