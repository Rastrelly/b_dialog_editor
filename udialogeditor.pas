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
        actul:integer;

        ulines:array of uline;

        procedure addul;
        procedure remul;
        procedure moveul(dir:integer);

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
    Label1: TLabel;
    Label10: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lbULines: TListBox;
    edPerkList: TListBox;
    edFlagList: TListBox;
    MainMenu1: TMainMenu;
    memoNodeText: TMemo;
    memoULine: TMemo;
    MenuItem1: TMenuItem;
    miSave: TMenuItem;
    miOpen: TMenuItem;
    Panel1: TPanel;
    Panel10: TPanel;
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
    procedure bUpdateLineClick(Sender: TObject);
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

  al:=actul;

  a:=al;
  b:=al+dir;

  if (b>=0) and (b<Length(ulines)) then
  begin
    cul:=ulines[a];
    ulines[a]:=ulines[b];
    ulines[b]:=cul;
  end;

end;


procedure Tform1.UpdateUI;
var i,ull:integer;
begin

  //user line list
  ull:=length(cnode.ulines);
  lbULines.Clear;
  if (ull>0) then
  for i:=0 to ull-1 do
  begin
    lbULines.AddItem(cnode.ulines[i].text,lbULines);
  end;

  //user line data
  if (ull>0) then memoULine.Text:=cnode.ulines[cnode.actul].text;

  if (ull>0) and (cnode.actul<ull) then
  lbULines.ItemIndex:=cnode.actul;

end;

procedure TForm1.bUpdateLineClick(Sender: TObject);
begin
  if (length(cnode.ulines)>0) then
  begin
    cnode.ulines[cnode.actul].text:=memoULine.Text;
    UpdateUI;
  end;
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
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  appfolder:=ExtractFileDir(Application.ExeName)+'\';
  StatusBar1.Panels[1].Text:=appfolder;
  LoadSettings;
  cnode:=TNode.Create;
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

