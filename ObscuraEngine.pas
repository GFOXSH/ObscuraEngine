unit ObscuraEngine;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TMyForm = class(TForm)
  procedure OnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  procedure OnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  procedure OnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
  
  RalseiAI = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;
  
  ImageProperties = record
    PosX, PosY: Integer;
    Bitmap: TBitMap;
    InteractionType: Byte;
    Image: TImage;
  end;

procedure GameInit(Sender: TObject);
procedure GameStart(FileName: String);
procedure CreateSurface(AX, AY, BX, BY, CX, CY, DX, DY: Integer);
procedure CreateRoom(FileName: String);
procedure CreateBackground(FileName: String; PosX, PosY: Integer; InteractionType: Byte);
procedure CreateForeground(FileName: String; PosX, PosY: Integer; InteractionType: Byte);
procedure CreateObject(FileName: String; PosX, PosY: Integer; InteractionType: Byte);
procedure GameStop();
function ISGameRun(): Boolean;

implementation

var
  Form: TMyForm;
  Ralsei: TImage;
  Emotion, Look, RalseiFN: String;
  Background, Foreground: array of ImageProperties;
  Surface: array of array of Boolean;
  Frame: Byte;
  Speed: Word;
  AI: RalseiAI;
  IsCanRun: Boolean;

function IsGameRun(): Boolean;
begin
  if AI <> nil then
    Result := true
  else
    Result := false;
end;

procedure Walk(Direction: Byte);
begin
  case Direction of
    0:Look := 'WalkUp';
    1:Look := 'WalkRight';
    2:Look := 'WalkDown';
    3:Look := 'WalkLeft';
  end;
  
  if Frame > 3 then
    Frame := 0;

  case Direction of
    0:Ralsei.Top := Ralsei.Top - 1;
    1:Ralsei.Left := Ralsei.Left + 1;
    2:Ralsei.Top := Ralsei.Top + 1;
    3:Ralsei.Left := Ralsei.Left - 1;
    4:Frame := 1;
  end;

  Ralsei.Picture.LoadFromFile('Assets\' + RalseiFN + Look + Emotion + IntToStr(Frame) + '.bmp');
  Inc(Frame);
  Ralsei.Update;

  Sleep(1000 div Speed);
end;

function NearestPoint(Coordinate: TPoint): TPoint;
var
  FreeSurface: array of TPoint;
  PosX, PosY, Counter: Integer;
  Current, Minimum: Real;
  Point: TPoint;
begin
  SetLength(FreeSurface, 0);
  Counter := 0;
  for PosX := 0 to Length(Surface) - 1 do
    for PosY :=0 to Length(Surface[PosX]) - 1 do
      if Surface[PosX, PosY] then
      begin
        SetLength(FreeSurface, Length(FreeSurface) + 1);
        FreeSurface[Counter].X := PosX;
        FreeSurface[Counter].Y := PosY;
        Inc(Counter);
      end;

  Minimum := Sqrt(Sqr(Coordinate.X - FreeSurface[0].X) + Sqr(Coordinate.Y - FreeSurface[0].Y));
  Point := FreeSurface[0];
  
  for Counter:= 0 to Length(FreeSurface) - 1 do
  begin
    Current := Sqrt(Sqr(Coordinate.X - FreeSurface[Counter].X) + Sqr(Coordinate.Y - FreeSurface[Counter].Y));
    if Current < Minimum then
    begin
      Point := FreeSurface[Counter];
      Minimum := Current;
    end;
  end;
  Result := Point;
end;

procedure FindPath(A, B: TPoint);
var
  Map: array of array of Integer;
  PosX, PosY, MaxPath, Temp, Counter: Integer;
  PathFound: Boolean;
  
begin
  SetLength(Map, Length(Surface), Length(Surface[0]));

  MaxPath := 0;

  for PosX := 0 to Length(Map) - 1 do
    for PosY :=0 to Length(Map[PosX]) - 1 do
      if Surface[PosX, PosY] then
      begin
        Map[PosX, PosY] := 0;
        Inc(MaxPath);
      end
      else
        Map[PosX, PosY] := -1;

  Map[B.X, B.Y] := 1;

  Dec(MaxPath);

  Temp := 0;

  PathFound := false;

  for Counter := 1 to MaxPath do
  begin
    if PathFound then
      Break;
    Inc(Temp);
    for PosX := 1 to Length(Map) - 2 do
      for PosY := 1 to Length(Map[PosX]) - 2 do
        if (Map[PosX, PosY] = Temp) then
        begin
          if Map[PosX + 1, PosY] = 0 then
            Map[PosX + 1, PosY] := Temp + 1;
          if Map[PosX - 1, PosY] = 0 then
            Map[PosX - 1, PosY] := Temp + 1;
          if Map[PosX, PosY + 1] = 0 then
            Map[PosX, PosY + 1] := Temp + 1;
          if Map[PosX, PosY - 1] = 0 then
            Map[PosX, PosY - 1] := Temp + 1;
          if Map[A.X, A.Y] <> 0 then
            PathFound := true;
        end;
  end;
  
  Temp := Map[A.X, A.Y];
  if Temp = 0 then
    Exit;

  PosX := A.X;
  PosY := A.Y;
  
  while Temp >= 2 do
    if Map[PosX, PosY] = Temp then
    begin
      if not IsCanRun then
        Exit;
      Dec(Temp);
      if Map[PosX + 1, PosY] = Temp then
      begin
        Walk(1);
        Inc(PosX);
      end;
      if Map[PosX - 1, PosY] = Temp then
      begin
        Walk(3);
        Dec(PosX);
      end;
      if Map[PosX, PosY + 1] = Temp then
      begin
        Walk(2);
        Inc(PosY);
      end;
      if Map[PosX, PosY - 1] = Temp then
      begin
        Walk(0);
        Dec(PosY);
      end;
    end;
    Walk(4);
end;

procedure TMyForm.OnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  //TODO
end;

procedure TMyForm.OnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  //TODO
end;

procedure TMyForm.OnClick(Sender: TObject);
begin
  //TODO
end;

procedure RalseiAI.Execute();
var
  A, B: TPoint;
begin
  Randomize;
  while IsCanRun do
  begin
    A.X := Ralsei.Left + Ralsei.Width div 2;
    A.Y := Ralsei.Top + Ralsei.Height div 2;
    B.X := Random(Form.ClientWidth);
    B.Y := Random(Form.ClientHeight);
    Speed := 100;
    if not Surface[B.X, B.Y] then
      B := NearestPoint(B);
    FindPath(A, B);
  end;
end;

procedure SpawnRalsei(PosX, PosY: Integer; Direction: Byte);
var
  Look: String;
begin
  Case Direction of
  1:Look := 'WalkUp';
  2:Look := 'WalkRight';
  3:Look := 'WalkDown';
  4:Look := 'WalkLeft';
  end;
  Ralsei := TImage.Create(Form);
  Ralsei.Parent := Form;
  Ralsei.Transparent := true;
  Ralsei.Picture.LoadFromFile('Assets\' + RalseiFN + Look + Emotion + '0.bmp');
  Ralsei.Width := Ralsei.Picture.Width;
  Ralsei.Height := Ralsei.Picture.Height;
  if PosX <> -1 then
    Ralsei.Left := PosX - Ralsei.Width div 2
  else
    Ralsei.Left := Form.ClientWidth div 2 - Ralsei.Width div 2;
  if PosY <> -1 then
    Ralsei.Top := PosY - Ralsei.Height div 2
  else
    Ralsei.Top := Form.ClientHeight div 2 - Ralsei.Height div 2;
  Ralsei.OnMouseDown := Form.OnMouseDown;
  Ralsei.OnMouseUp := Form.OnMouseUp;
  Ralsei.Update;
end;

procedure CreateSurface(AX, AY, BX, BY, CX, CY, DX, DY: Integer);
var
  Corners: array [0..3] of TPoint;
  rgn: HRGN;
  PosX, PosY: Integer;
begin
  Corners[0].X := AX;
  Corners[0].Y := AY;
  Corners[1].X := BX;
  Corners[1].Y := BY;
  Corners[2].X := CX;
  Corners[2].Y := CY;
  Corners[3].X := DX;
  Corners[3].Y := DY;

  SetLength(Surface, Form.ClientWidth, Form.ClientHeight);

  rgn := CreatePolygonRgn(Corners[0], Length(Corners), WINDING);

  for PosX := 0 to Form.ClientWidth - 1 do
    for PosY := 0 to Form.ClientHeight - 1 do
      if PtInRegion(rgn, PosX, PosY) then
        Surface[PosX, PosY] := true
      else
        Surface[PosX, PosY] := false;

  DeleteObject(rgn);
end;

procedure ExcludeFromSurface(Image: ImageProperties);
var
  PosX, PosY: Integer;
begin
  for PosX := Image.Image.Left to Image.Image.Left + Image.Image.Width do
    for PosY := Image.Image.Top to Image.Image.Top + Image.Image.Height do
      Surface[PosX, PosY] := false;
end;

procedure TestSurface();
var
  Canvas: TCanvas;
  PosX, PosY: Integer;
begin
  Canvas := Form.Canvas;
  for PosX := 0 to Form.ClientWidth - 1 do
    for PosY := 0 to Form.ClientHeight - 1 do
      if Surface[PosX, PosY] then
        Canvas.Pixels[PosX, PosY] := clWhite
      else
        Canvas.Pixels[PosX, PosY] := clBlack;
  InValidateRect(Form.Handle, nil, true);
end;

procedure CreateBackground(FileName: String; PosX, PosY: Integer; InteractionType: Byte);
begin
  SetLength(Background, Length(Background) + 1);
  Background[Length(Background) - 1].Bitmap := TBitMap.Create;
  Background[Length(Background) - 1].Bitmap.LoadFromFile('Assets\' + FileName + '0.bmp');
  Background[Length(Background) - 1].PosX := PosX - Background[Length(Background) - 1].Bitmap.Width div 2;
  Background[Length(Background) - 1].PosY := PosY - Background[Length(Background) - 1].Bitmap.Height div 2;
  Background[Length(Background) - 1].InteractionType := InteractionType;
end;

procedure CreateForeground(FileName: String; PosX, PosY: Integer; InteractionType: Byte);
begin
  SetLength(Foreground, Length(Foreground) + 1);
  Foreground[Length(Foreground) - 1].Bitmap := TBitMap.Create;
  Foreground[Length(Foreground) - 1].Bitmap.LoadFromFile('Assets\' + FileName + '0.bmp');
  Foreground[Length(Foreground) - 1].PosX := PosX - Foreground[Length(Foreground) - 1].Bitmap.Width div 2;
  Foreground[Length(Foreground) - 1].PosY := PosY - Foreground[Length(Foreground) - 1].Bitmap.Height div 2;
  Foreground[Length(Foreground) - 1].InteractionType := InteractionType;
end;

procedure CreateObject(FileName: String; PosX, PosY: Integer; InteractionType: Byte);
var
  HalfHeight: Integer;
  Rect1, Rect2: TRect;
  Temp: TBitMap;
begin
  SetLength(Background, Length(Background) + 1);
  Background[Length(Background) - 1].PosX := PosX;
  Background[Length(Background) - 1].InteractionType := InteractionType;

  SetLength(Foreground, Length(Foreground) + 1);

  Foreground[Length(Foreground) - 1].InteractionType := InteractionType;

  Temp := TBitMap.Create;
  Temp.LoadFromFile('Assets\' + FileName + '0.bmp');

  Background[Length(Background) - 1].Bitmap := TBitMap.Create;
  Foreground[Length(Foreground) - 1].Bitmap := TBitMap.Create;

  HalfHeight := Temp.Height div 2;

  Background[Length(Background) - 1].PosX := PosX - Temp.Width div 2;
  Foreground[Length(Foreground) - 1].PosX := PosX - Temp.Width div 2;

  Rect1 := Rect(0, 0, Temp.Width, HalfHeight);
  Rect2 := Rect(0, HalfHeight, Temp.Width, Temp.Height);

  Foreground[Length(Foreground) - 1].Bitmap.Width := Temp.Width;
  Foreground[Length(Foreground) - 1].Bitmap.Height := HalfHeight;
  Background[Length(Background) - 1].Bitmap.Width := Temp.Width;
  Background[Length(Background) - 1].Bitmap.Height := Temp.Height - HalfHeight;

  Foreground[Length(Foreground) - 1].PosY := PosY - HalfHeight;
  Background[Length(Background) - 1].PosY := Foreground[Length(Background) - 1].PosY + Foreground[Length(Background) - 1].Bitmap.Height;

  Foreground[Length(Foreground) - 1].Bitmap.Canvas.CopyRect(Rect(0, 0, Foreground[Length(Foreground) - 1].Bitmap.Width, Foreground[Length(Foreground) - 1].Bitmap.Height), Temp.Canvas, Rect1);
  Background[Length(Background) - 1].Bitmap.Canvas.CopyRect(Rect(0, 0, Background[Length(Background) - 1].Bitmap.Width, Background[Length(Background) - 1].Bitmap.Height), Temp.Canvas, Rect2);
end;

procedure SpawnBackground();
var
  Counter: Byte;
begin
  if Length(Background) <> 0 then
  for Counter := 0 to Length(Background) - 1 do
  begin
    Background[Counter].Image := TImage.Create(Form);
    Background[Counter].Image.Parent := Form;
    Background[Counter].Image.Transparent := true;
    Background[Counter].Image.Picture.Bitmap := Background[Counter].Bitmap;
    Background[Counter].Image.Width := Background[Counter].Image.Picture.Width;
    Background[Counter].Image.Height := Background[Counter].Image.Picture.Height;
    Background[Counter].Image.Left := Background[Counter].PosX;
    Background[Counter].Image.Top := Background[Counter].PosY;
    ExcludeFromSurface(Background[Counter]);
    //Background[Counter].Image.SendToBack;
    Background[Counter].Image.OnClick := Form.OnClick;
    Background[Counter].Image.Update;
  end;
end;

procedure SpawnForeground();
var
  Counter: Byte;
begin
  if Length(Foreground) <> 0 then
    for Counter := 0 to Length(Foreground) - 1 do
    begin
      Foreground[Counter].Image := TImage.Create(Form);
      Foreground[Counter].Image.Parent := Form;
      Foreground[Counter].Image.Transparent := true;
      Foreground[Counter].Image.Picture.Bitmap := Foreground[Counter].Bitmap;
      Foreground[Counter].Image.Width := Foreground[Counter].Image.Picture.Width;
      Foreground[Counter].Image.Height := Foreground[Counter].Image.Picture.Height;
      Foreground[Counter].Image.Left := Foreground[Counter].PosX;
      Foreground[Counter].Image.Top := Foreground[Counter].PosY;
      ExcludeFromSurface(Foreground[Counter]);
      //Foreground[Counter].Image.BringToFront;
      Foreground[Counter].Image.OnClick := Form.OnClick;
      Foreground[Counter].Image.Update;
    end;
end;

procedure CreateRoom(FileName: String);
var
  Background: TImage;
begin
  Background := TImage.Create(Form);
  Background.Parent := Form;
  Background.Picture.Bitmap.LoadFromFile('Assets\' + FileName + '.bmp');
  Background.Align := alClient;
end;

procedure LoadGame();
begin
  //TODO
  Emotion := 'Normal';
  SpawnBackground();
  SpawnRalsei(-1, -1, 3);
  SpawnForeground();
  TestSurface();
  IsCanRun := true;
  AI := RalseiAI.Create(false);
end;

procedure GameInit(Sender: TObject);
begin
  if Sender is TForm then
    Form := TMyForm(Sender);
  Form.DoubleBuffered := true;
  SetLength(Background, 0);
  SetLength(Foreground, 0);
  AI := nil;
end;

procedure GameStart(FileName: String);
begin
  RalseiFN := FileName;
  Frame := 1;
  LoadGame();
end;

procedure GameStop();
begin
  if AI <> nil then
  begin
    IsCanRun := false;
    AI.WaitFor;
    AI := nil;
  end;
end;

end.
