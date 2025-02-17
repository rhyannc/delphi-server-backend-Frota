unit Controllers.Services;

interface

uses Horse,
     System.JSON,
     System.SysUtils,
     DM;

     procedure RegistrarRotas;
     procedure ListarServices(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
     procedure InsertService(Req: THorseRequest; Res: THorseResponse; Next: Tproc);

implementation

procedure RegistrarRotas;
begin
    // Configurações de endpoints do Horse
    THorse.Get('/listarservices',  ListarServices);
    THorse.Post('/postservice',  InsertService);

end;

procedure ListarServices(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
begin
      try
          dm  := TDtm.Create(nil);
          Res.Send(dm.ListarServices()).Status(200);
      finally
          FreeAndNil(dm);
      end;
end;

procedure InsertService(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  body: TJSONObject;
  description: string;
begin
      try
        try
            dm          := TDtm.Create(nil);
            body        := Req.Body<TJSONObject>;

            description      := body.GetValue<string>('description', '');

            Res.Send(dm.InsertService(description)).Status(201);

        except
          on ex:exception do
            Res.Send('Houve  um erro:' + ex.Message).Status(502);     //DEU ERRO
        end;
      finally
          FreeAndNil(dm);
      end;
end;




end.
