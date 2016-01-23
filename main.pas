unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, WinSock, StdCtrls, Menus, ExtCtrls, ComCtrls, dl1, dl2;

const
  WM_MYSOCKET = WM_USER + 1;

type
  str = array[0..255] of char;
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    Shape1: TShape;
    N8: TMenuItem;
    StatusBar1: TStatusBar;
    procedure N6Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SetColorOnShape1(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SetColorOnShape2(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure N8Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
  private
    { Private declarations }
    procedure RecvSock(var Msg:TMessage); message WM_MYSOCKET;
    procedure SendSock(Mes: string);
    procedure LoadGame();
    procedure EndGame();
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  InetAddr, InetAddrOut: SOCKADDR_IN;
  sock: TSocket;
  bPriem: (prnot, prinout, proutin);
  Pole1: array[0..9, 0..9] of TShape;
  Pole2: array[0..9, 0..9] of TShape;
  bShips: byte;
  bShipsPlaced: byte;
  bShipsYouKilled: byte;
  bShipsHeKilled: byte;
  vx, vy : byte;
  blVystrel: boolean;
  blGameStatus: boolean;
  iLocalPort: integer;
  sServerAddr: string;
  iServerPort: integer;

implementation

{$R *.dfm}
{Новая игра}
procedure TForm1.LoadGame();
var
 i,j,h,w:integer;
begin
 bShips := 5;
 h:=10;
 w:=10;
 {Поле игрока}
 for i:=0 to 9 do
 begin
  for j:=0 to 9 do
  begin
   Pole1[i,j]:=TShape.Create(Self);
   Pole1[i,j].Parent:=Self;
   Pole1[i,j].Left:=w+25*j;
   Pole1[i,j].Top:=h+25*i;
   Pole1[i,j].Height:=25;
   Pole1[i,j].Width:=25;
   Pole1[i,j].Brush.Color:=clSkyBlue;
   Pole1[i,j].OnMouseUp:= SetColorOnShape1;
  end;
 end;
 w:=266;
 {Поле соперника}
 for i:=0 to 9 do
 begin
  for j:=0 to 9 do
  begin
   Pole2[i,j]:=TShape.Create(Self);
   Pole2[i,j].Parent:=Self;
   Pole2[i,j].Left:=w+25*j;
   Pole2[i,j].Top:=h+25*i;
   Pole2[i,j].Height:=25;
   Pole2[i,j].Width:=25;
   Pole2[i,j].OnMouseUp:= SetColorOnShape2;
  end;
 end;
end;

procedure TForm1.SetColorOnShape1(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
 i,j:integer;
 f:Boolean;
begin
 f:=false;
 for i:=0 to 9 do
  for j:=0 to 9 do
   if Not blGameStatus then
    if Sender = Pole1[i,j] then
     if bShipsPlaced < bShips then
     begin
      if Pole1[i,j].Brush.Color = clBlack then f := true;
      if Pole1[i-1,j+1].Brush.Color = clBlack then f := true;
      if Pole1[i+1,j-1].Brush.Color = clBlack then f := true;
      if Pole1[i+1,j+1].Brush.Color = clBlack then f := true;
      if Pole1[i-1,j-1].Brush.Color = clBlack then f := true;
      if Not f then
      begin
       Pole1[i,j].Brush.Color:=clBlack;
       inc(bShipsPlaced);
      end
     end
     else
     begin
      blGameStatus:=true;
      N6.Enabled:=true;
      N7.Enabled:=true;
     end;
end;

procedure TForm1.SetColorOnShape2(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
 i,j:integer;
begin
if blVystrel then
 for i:=0 to 9 do
  for j:=0 to 9 do
   if Sender = Pole2[i,j] then     
    if Pole2[i,j].Brush.Color = clWhite then
     begin
      vx:=i; vy:=j;
      SendSock(IntToStr(10*i+j));
      bPriem := proutin;
     end;
end;
{Коенц игры}
procedure TForm1.EndGame();
var
 on_off_sock: longint;
 i, j: byte;
begin
 for i:=0 to 9 do
  for j:=0 to 9 do
   begin
   try
    Pole1[i,j].Destroy;
    Pole2[i,j].Destroy;
   except
   end;
   end;
 bShipsPlaced:=0;
 bShipsYouKilled:=0;
 bShipsHeKilled:=0;
 blGameStatus:=false;
 on_off_sock:=0;
 ioctlsocket(sock, FIONBIO, on_off_sock);
 closesocket(sock);
 WSACleanup;
 N8.Enabled:=true;
end;
{Прием данных из сокета}
procedure TForm1.RecvSock(var Msg:TMessage);
var
 Buffer: str;
 iStruckSize: integer;
 i, j: byte;
begin
 if ((Msg.Msg = WM_MYSOCKET) and (Msg.lParam = FD_READ)) then
 begin {IF 1}
  ZeroMemory(@Buffer, SizeOf(str));
  if recvfrom(sock, Buffer, 256, 0, InetAddrOut, iStruckSize) > 0 then
  begin {IF 2}
   case bPriem of {CASE 1}
    prinout:
    begin {prinout}
     i := StrToInt(Buffer) div 10;
     j:= StrToInt(Buffer) mod 10;
     if Pole1[i,j].Brush.Color = clBlack then
     begin
      SendSock('popal');
      Pole1[i,j].Brush.Color := clRed;
      blVystrel := false;
      bPriem := prinout;
      inc(bShipsHeKilled);
      StatusBar1.Panels[1].Text := 'Ждите...';
     end
     else
     begin
      SendSock('nepopal');
      Pole1[i,j].Brush.Color := clHighlight;
      blVystrel := true;
      bPriem := prnot;
      StatusBar1.Panels[1].Text := 'Стреляйте...';
     end;
     StatusBar1.Panels[0].Text := 'Счет: ' + IntToStr(bShipsYouKilled) + '-' + IntToStr(bShipsHeKilled);
     if bShipsYouKilled = bShips then
     begin
      ShowMessage('Вы выиграли!');
      StatusBar1.Panels[1].Text := '';
      EndGame();
     end;
     if bShipsHeKilled = bShips then
     begin
      ShowMessage('Вы проиграли!');
      StatusBar1.Panels[1].Text := '';
      EndGame();
     end;
    end; {END prinout}
    proutin:
    begin {proutin}
     if StrComp(Buffer, PChar('popal')) = 0 then
     begin
      Pole2[vx,vy].Brush.Color := clRed;
      inc(bShipsYouKilled);
      StatusBar1.Panels[1].Text := 'Стреляйте...';
     end;
     if StrComp(Buffer, PChar('nepopal')) = 0 then
     begin
      Pole2[vx,vy].Brush.Color := clHighlight;
      StatusBar1.Panels[1].Text := 'Ждите...';
     end;
     bPriem:= prinout;
     StatusBar1.Panels[0].Text := 'Счет: ' + IntToStr(bShipsYouKilled) + '-' + IntToStr(bShipsHeKilled);
     if bShipsYouKilled = bShips then
     begin
      ShowMessage('Вы выиграли!');
      StatusBar1.Panels[1].Text := '';
      EndGame();
     end;
     if bShipsHeKilled = bShips then
     begin
      ShowMessage('Вы проиграли!');
      StatusBar1.Panels[1].Text := '';
      EndGame();
     end;
    end; {END proutin}
    prnot:
   end; {END CASE 1}
  end; {END IF 2}
 end; {EDN IF 1}
end;
procedure TForm1.SendSock(Mes: string);
var
 Buffer: str;
begin
 ZeroMemory(@Buffer, SizeOf(str));
 StrCopy(Buffer, PChar(Mes));
 sendto(sock, Buffer, StrLen(Buffer) + 1, 0, InetAddrOut, SizeOf(InetAddrOut));
end;

//Сервер
procedure TForm1.N6Click(Sender: TObject);
var
 ws: TWSADATA;
 on_off_sock: longint;
begin
 if WSAStartup($0202, ws)=0 then
  begin
    InetAddr.sin_family := AF_INET;
    InetAddr.sin_addr.s_addr := INADDR_ANY;
    InetAddr.sin_port := htons (iLocalPort);
    sock := socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (sock <> INVALID_SOCKET) then
    begin
      if bind(sock, InetAddr, sizeof(InetAddr)) <> SOCKET_ERROR then
      begin
        N7.Enabled:=false;
        N6.Enabled:=false;
        on_off_sock:=1;
        ioctlsocket(sock, FIONBIO, on_off_sock);
        WSAAsyncSelect(sock, Form1.Handle, WM_MYSOCKET, FD_READ);
        bPriem := prinout;
        blVystrel:=false;
        StatusBar1.Panels[1].Text := 'Ждите...';
      end
      else
        ShowMessage('bind () с ошибкой ' + IntToStr(GetLastError));
    end
    else
      ShowMessage('Ошибка создания сокета ' + IntToStr(WSAGetLastError));
  end
  else
    ShowMessage('Невозможно загрузить библиотеку WinSock2');
end;
//Клиент
procedure TForm1.N7Click(Sender: TObject);
var
 ws: TWSADATA;
 on_off_sock: longint;
begin
 if WSAStartup($0202, ws)=0 then
  begin
    InetAddr.sin_family := AF_INET;
    InetAddr.sin_addr.s_addr := inet_addr(PChar(sServerAddr));
    InetAddr.sin_port := htons(iServerPort);
    sock := socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    //--
    if (sock <> INVALID_SOCKET) then
    begin
     N7.Enabled:=false;
     N6.Enabled:=false;
     InetAddrOut := InetAddr;
     on_off_sock :=1;
     ioctlsocket(sock, FIONBIO, on_off_sock);
     WSAAsyncSelect(sock, Form1.Handle, WM_MYSOCKET, FD_READ);
     bPriem := prnot;
     blVystrel:=true;
     StatusBar1.Panels[1].Text := 'Стреляйте...';
    end
    else
      ShowMessage('Oshibka sozdaniya soketa ' + IntToStr(WSAGetLastError));
  end
  else
    ShowMessage('Невозможно загрузить библиотеку WinSock2');
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
 EndGame();
end;

procedure TForm1.N8Click(Sender: TObject);
begin
 LoadGame();
 N8.Enabled:=false;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
 iLocalPort:=50;
 sServerAddr:='127.0.0.1';
 iServerPort:=50;
end;

procedure TForm1.N2Click(Sender: TObject);
begin
 Application.Terminate;
end;

procedure TForm1.N4Click(Sender: TObject);
begin
 Form3.Left := Form1.Left + (Form1.Width - Form3.Width) div 2;
 Form3.Top := Form1.Top + (Form1.Height - Form3.Height) div 2;
 Form3.Edit1.Text := sServerAddr;
 Form3.Edit2.Text := IntToStr(iServerPort);
 if Form3.ShowModal = mrOK then
 begin
  sServerAddr:= Form3.Edit1.Text;
  iServerPort := StrToInt(Form3.Edit2.Text);
 end;
end;

procedure TForm1.N5Click(Sender: TObject);
begin
 Form2.Left := Form1.Left + (Form1.Width - Form2.Width) div 2;
 Form2.Top := Form1.Top + (Form1.Height - Form2.Height) div 2;
 Form2.Edit1.Text:=IntToStr(iLocalPort);
 if Form2.ShowModal = mrOK then
 begin
  iLocalPort:=StrToInt(Form2.Edit1.Text);
 end;
end;

end.
