unit Controllers.ActService;

interface

uses Horse,
     System.JSON,
     System.SysUtils,
     DM;

     procedure RegistrarRotas;
     procedure InsertService(Req: THorseRequest; Res: THorseResponse; Next: Tproc);

implementation

procedure RegistrarRotas;
begin
    // Configurações de endpoints do Horse
    THorse.Post('/postservice',  InsertService);

end;

procedure InsertService(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  body: TJSONObject;
  description: string;
  id_driver, id_vehicle: integer;
  value: Currency;
begin
      try
        try
            dm          := TDtm.Create(nil);
            body        := Req.Body<TJSONObject>;

            id_driver     := body.GetValue<integer>('id_driver', 0);
            id_vehicle    := body.GetValue<integer>('id_vehicle', 0);
            value         := body.GetValue<Currency>('value', 0);
            description   := body.GetValue<string>('description', '');

            Res.Send(dm.InsertActService(id_driver, id_vehicle, value, description)).Status(201);

        except
          on ex:exception do
            Res.Send('Houve  um erro:' + ex.Message).Status(502);     //DEU ERRO
        end;
      finally
          FreeAndNil(dm);
      end;
end;

end.
