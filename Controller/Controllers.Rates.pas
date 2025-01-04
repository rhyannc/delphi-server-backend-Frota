unit Controllers.Rates;

interface

uses Horse,
     System.JSON,
     System.SysUtils,
     DM;

     procedure RegistrarRotas;
     procedure ListarRates(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
     procedure ListarRateClient(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
     procedure InsertRate(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
     procedure UpdateRate(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
     procedure DeleteRate(Req: THorseRequest; Res: THorseResponse; Next: Tproc);

implementation

procedure RegistrarRotas;
begin
    // Configurações de endpoints do Horse
    THorse.Get('/listarrates',  ListarRates);
    THorse.Post('/listarratesclient',  ListarRateClient);
    THorse.Post('/postrate',  InsertRate);
    THorse.Put('/updaterate', UpdateRate);
    THorse.Delete('/deleterate/:id_rate',  DeleteRate);

end;


procedure ListarRates(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
begin
      try
          dm  := TDtm.Create(nil);
          Res.Send(dm.ListarRates()).Status(200);
      finally
          FreeAndNil(dm);
      end;
end;

procedure ListarRateClient(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  body, Json_ret: TJSONObject;
  id_client: integer;
begin
      try
          dm  := TDtm.Create(nil);
          body     := Req.Body<TJSONObject>;
          id_client := body.GetValue<integer>('id_client', 0);

            Json_ret := dm.ListarRateClient(id_client);
            Res.Send<TJsonObject>(Json_ret).Status(201);

      finally
          FreeAndNil(dm);
      end;
end;

procedure InsertRate(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  body: TJSONObject;
  rate, rate_driver: Currency;
  id_client, id_vehicle, id_material, id_origin, id_destination: integer;
begin
      try
        try
            dm          := TDtm.Create(nil);
            body        := Req.Body<TJSONObject>;

            id_client    := body.GetValue<integer>('id_client', 0);
            id_material     := body.GetValue<integer>('id_material', 0);
            id_origin       := body.GetValue<integer>('id_origin', 0);
            id_destination  := body.GetValue<integer>('id_destination', 0);
            rate            := body.GetValue<Currency>('rate', 0);
            rate_driver     := body.GetValue<Currency>('rate_driver', 0);


            Res.Send(dm.InsertRate(id_client, id_origin, id_destination, id_material,  rate, rate_driver)).Status(201);

        except
          on ex:exception do
            Res.Send('Houve  um erro:' + ex.Message).Status(502);     //DEU ERRO
        end;
      finally
          FreeAndNil(dm);
      end;
end;

// Função para Atualizar um registro específico
procedure UpdateRate(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  body, Json_ret: TJSONObject;
  rate, rate_driver: Currency;
  id_rate, id_client, id_vehicle, id_material, id_origin, id_destination: integer;
begin
     try
        try
            dm       := TDtm.Create(nil);

            body     := Req.Body<TJSONObject>;
            id_rate := body.GetValue<integer>('id_rate', 0);

            id_client    := body.GetValue<integer>('id_client', 0);
            id_material     := body.GetValue<integer>('id_material', 0);
            id_origin       := body.GetValue<integer>('id_origin', 0);
            id_destination  := body.GetValue<integer>('id_destination', 0);
            rate            := body.GetValue<Currency>('rate', 0);
            rate_driver     := body.GetValue<Currency>('rate_driver', 0);

            Json_ret := dm.UpdateRate(id_rate, id_client, id_material, id_origin, id_destination, rate, rate_driver);
            Res.Send<TJsonObject>(Json_ret).Status(201);

        except
          on ex:exception do
            Res.Send('Ops! ' + ex.Message).Status(502);     //DEU ERRO
        end;
      finally
          FreeAndNil(dm);
      end;
end;

// Função para deletar um registro específico
procedure DeleteRate(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  id_rate: integer;
  Json_ret: TJSONObject;
begin
     try
        try
            dm       := TDtm.Create(nil);

            try
               id_rate  := Req.Params.Items['id_rate'].ToInteger;
            except
               id_rate := 0;
            end;

            Json_ret := dm.DeleteRate(id_rate);


            Res.Send('Rate Id  ' + inttostr(id_rate) + '  Foi Excluido!').Status(200);

        except
          on ex:exception do
            Res.Send('Ops! ' + ex.Message).Status(404);     //DEU ERRO
        end;
      finally
          FreeAndNil(dm);
      end;
end;

end.
