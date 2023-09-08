unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ObscuraEngine, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  if not IsGameRun then
  begin
    CreateSurface(50, 50, 450, 50, 450, 450, 50, 450);
    CreateRoom('Room0');
    CreateObject('Table', 100, 100, 0);
    CreateObject('Table', 200, 100, 0);
    CreateObject('Table', 300, 100, 0);
    CreateObject('Table', 400, 100, 0);
    CreateObject('Table', 100, 200, 0);
    CreateObject('Table', 200, 200, 0);
    CreateObject('Table', 300, 200, 0);
    CreateObject('Table', 400, 200, 0);
    CreateObject('Table', 100, 300, 0);
    CreateObject('Table', 200, 300, 0);
    CreateObject('Table', 300, 300, 0);
    CreateObject('Table', 400, 300, 0);
    CreateObject('Table', 100, 400, 0);
    CreateObject('Table', 200, 400, 0);
    CreateObject('Table', 300, 400, 0);
    CreateObject('Table', 400, 400, 0);
    GameStart('Ralsei');
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  GameInit(Form1);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  GameStop();
  Application.Terminate;
end;

end.
 