program AwFrotaServer;

uses
  Vcl.Forms,
  UnitPrincipal in 'UnitPrincipal.pas' {FrmPrincipal},
  DM in 'DM.pas' {Dtm: TDataModule},
  Controllers.Drivers in 'Controller\Controllers.Drivers.pas',
  Controllers.Vehicles in 'Controller\Controllers.Vehicles.pas',
  Controllers.Points in 'Controller\Controllers.Points.pas',
  Controllers.Material in 'Controller\Controllers.Material.pas',
  Controllers.ActAbastecimento in 'Controller\Controllers.ActAbastecimento.pas',
  Controllers.ActService in 'Controller\Controllers.ActService.pas',
  Controllers.ActTrips in 'Controller\Controllers.ActTrips.pas',
  Controllers.Relatorios in 'Controller\Controllers.Relatorios.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.CreateForm(TDtm, Dtm);
  Application.Run;
end.
