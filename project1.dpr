program Project1;

uses
  Forms,
  main in 'main.pas' {Form1},
  dl2 in 'dl2.pas' {Form2},
  dl1 in 'dl1.pas' {Form3};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
