unit Controllers.Drivers;

interface

uses Horse,
     System.JSON,
     System.SysUtils,
     DM;

     procedure RegistrarRotas;
     procedure ListarDrivers(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
     procedure ListarDriverID(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
     procedure InsertDriver(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
     procedure UpdateDriver(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
     procedure ExcluirDriver(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
     procedure DeleteDriver(Req: THorseRequest; Res: THorseResponse; Next: Tproc);

implementation

procedure RegistrarRotas;
begin
    // Configura��es de endpoints do Horse
    THorse.Get('/listardrivers',  ListarDrivers);
    THorse.Post('/listardriverid',  ListarDriverID);
    THorse.Post('/postdriver',  InsertDriver);
    THorse.Put('/updatedriver', UpdateDriver);
    THorse.Delete('/excluirdriver/:id_driver',  ExcluirDriver);
    THorse.Delete('/deletedriver/:id_driver',  DeleteDriver);

end;

procedure ListarDrivers(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
begin
      try
          dm  := TDtm.Create(nil);
          Res.Send(dm.ListarDrivers()).Status(200);
      finally
          FreeAndNil(dm);
      end;
end;

procedure ListarDriverID(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  id_driver: integer;
  body: TJSONObject;
begin
      try
          dm       := TDtm.Create(nil);
          body     := Req.Body<TJSONObject>;
          id_driver := body.GetValue<integer>('id_driver', 0);

          Res.Send(dm.ListarDriverID(id_driver)).Status(200);
      finally
          FreeAndNil(dm);
      end;
end;

procedure InsertDriver(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  body: TJSONObject;
  name, cpf, phone, commission: string;
  percent_commission: Currency;
begin
      try
        try
            dm          := TDtm.Create(nil);
            body        := Req.Body<TJSONObject>;

            name                 := body.GetValue<string>('name', '');
            cpf                  := body.GetValue<string>('cpf', '');
            phone                := body.GetValue<string>('phone', '');
            commission           := body.GetValue<string>('commission', '');
            percent_commission   := body.GetValue<Currency>('percent_commission', 0);

            Res.Send(dm.InsertDriver(name, cpf, phone, commission, percent_commission)).Status(201);

        except
          on ex:exception do
            Res.Send('Houve  um erro:' + ex.Message).Status(502);     //DEU ERRO
        end;
      finally
          FreeAndNil(dm);
      end;
end;

// Fun��o para Atualizar um registro espec�fico
procedure UpdateDriver(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  body, Json_ret: TJSONObject;
  name, cpf, phone, commission: string;
  id_driver: integer;
  percent_commission: Currency;
begin
     try
        try
            dm       := TDtm.Create(nil);

            body     := Req.Body<TJSONObject>;
            id_driver := body.GetValue<integer>('id_driver', 0);
            name     := body.GetValue<string>('name', '');

            cpf                := body.GetValue<string>('cpf', '');
            phone                := body.GetValue<string>('phone', '');
            commission           := body.GetValue<string>('commission', '');
            percent_commission   := body.GetValue<Currency>('percent_commission', 0);

            Json_ret := dm.UpdateDriver(id_driver, name, cpf, phone, commission, percent_commission);
            Res.Send<TJsonObject>(Json_ret).Status(201);

        except
          on ex:exception do
            Res.Send('Ops! ' + ex.Message).Status(502);     //DEU ERRO
        end;
      finally
          FreeAndNil(dm);
      end;
end;

// Fun��o para "Excluir" remover da vis�o os dados desse Driver
procedure ExcluirDriver(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  id_driver: integer;
  Json_ret: TJSONObject;
begin
     try
        try
            dm       := TDtm.Create(nil);

            try
               id_driver  := Req.Params.Items['id_driver'].ToInteger;
            except
               id_driver := 0;
            end;

            Json_ret := dm.ExcluirDriver(id_driver);


            Res.Send('Driver Id  ' + inttostr(id_driver) + '  Foi Excluido!').Status(200);

        except
          on ex:exception do
            Res.Send('Ops! ' + ex.Message).Status(404);     //DEU ERRO
        end;
      finally
          FreeAndNil(dm);
      end;
end;


// Fun��o para deletar um registro espec�fico
procedure DeleteDriver(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  id_driver: integer;
  Json_ret: TJSONObject;
begin
     try
        try
            dm       := TDtm.Create(nil);

            try
               id_driver  := Req.Params.Items['id_driver'].ToInteger;
            except
               id_driver := 0;
            end;

            Json_ret := dm.DeleteDriver(id_driver);


            Res.Send('Driver Id  ' + inttostr(id_driver) + '  Foi Excluido!').Status(200);

        except
          on ex:exception do
            Res.Send('Ops! ' + ex.Message).Status(404);     //DEU ERRO
        end;
      finally
          FreeAndNil(dm);
      end;
end;

end.
