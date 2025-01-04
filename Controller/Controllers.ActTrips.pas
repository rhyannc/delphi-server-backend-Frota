unit Controllers.ActTrips;

interface

uses Horse,
     System.JSON,
     System.SysUtils,
     DM;

     procedure RegistrarRotas;
     procedure InsertTrips(Req: THorseRequest; Res: THorseResponse; Next: Tproc);

implementation

procedure RegistrarRotas;
begin
    // Configurações de endpoints do Horse
    THorse.Post('/posttrips',  InsertTrips);

end;

procedure InsertTrips(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  body: TJSONObject;
  peso: Currency;
  notafiscal: string;
  id_driver, id_vehicle, id_material, id_origin, id_destination, id_client: integer;
begin
      try
        try
            dm          := TDtm.Create(nil);
            body        := Req.Body<TJSONObject>;

            id_driver       := body.GetValue<integer>('id_driver', 0);
            id_vehicle      := body.GetValue<integer>('id_vehicle', 0);
            id_client      := body.GetValue<integer>('id_client', 0);
            id_material     := body.GetValue<integer>('id_material', 0);
            id_origin       := body.GetValue<integer>('id_origin', 0);
            id_destination  := body.GetValue<integer>('id_destination', 0);
            peso            := body.GetValue<Currency>('peso', 0);
            notafiscal            := body.GetValue<string>('notafiscal', '');

            Res.Send(dm.InsertActTrips(id_driver, id_vehicle, id_material, id_origin, id_destination, id_client, notafiscal, peso )).Status(201);

        except
          on ex:exception do
            Res.Send('Houve  um erro:' + ex.Message).Status(502);     //DEU ERRO
        end;
      finally
          FreeAndNil(dm);
      end;
end;

end.
