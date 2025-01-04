unit Controllers.Vehicles;

interface

uses Horse,
     System.JSON,
     System.SysUtils,
     DM;

     procedure RegistrarRotas;
     procedure ListarVehicles(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
     procedure InsertVehicle(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
     procedure UpdateVehicle(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
     procedure DeleteVehicle(Req: THorseRequest; Res: THorseResponse; Next: Tproc);

implementation

procedure RegistrarRotas;
begin
    // Configurações de endpoints do Horse
    THorse.Get('/listarvehicles',  ListarVehicles);
    THorse.Post('/postvehicle',  InsertVehicle);
    THorse.Put('/updatevehicle', UpdateVehicle);
    THorse.Delete('/deletevehicle/:id_vehicle',  DeleteVehicle);

end;

procedure ListarVehicles(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
begin
      try
          dm  := TDtm.Create(nil);
          Res.Send(dm.ListarVehicles()).Status(200);
      finally
          FreeAndNil(dm);
      end;
end;

procedure InsertVehicle(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  body: TJSONObject;
  plate, tipo, brand: string;
begin
      try
        try
            dm          := TDtm.Create(nil);
            body        := Req.Body<TJSONObject>;

            plate      := body.GetValue<string>('plate', '');
            tipo      := body.GetValue<string>('tipo', '');
            brand      := body.GetValue<string>('brand', '');

            Res.Send(dm.InsertVehicle(plate, tipo, brand)).Status(201);

        except
          on ex:exception do
            Res.Send('Houve  um erro:' + ex.Message).Status(502);     //DEU ERRO
        end;
      finally
          FreeAndNil(dm);
      end;
end;

// Função para Atualizar um registro específico
procedure UpdateVehicle(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  body, Json_ret: TJSONObject;
  plate, tipo, brand: string;
  id_vehicle: integer;
begin
     try
        try
            dm       := TDtm.Create(nil);

            body       := Req.Body<TJSONObject>;
            id_vehicle := body.GetValue<integer>('id_vehicle', 0);
            plate      := body.GetValue<string>('plate', '');
            tipo       := body.GetValue<string>('tipo', '');
            brand      := body.GetValue<string>('brand', '');

            Json_ret := dm.UpdateVehicle(id_vehicle, plate, tipo, brand);
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
procedure DeleteVehicle(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  id_vehicle: integer;
  Json_ret: TJSONObject;
begin
     try
        try
            dm       := TDtm.Create(nil);

            try
               id_vehicle  := Req.Params.Items['id_vehicle'].ToInteger;
            except
               id_vehicle := 0;
            end;

            Json_ret := dm.DeleteVehicle(id_vehicle);


            Res.Send('Vvehicle Id  ' + inttostr(id_vehicle) + '  Foi Excluido!').Status(200);

        except
          on ex:exception do
            Res.Send('Ops! ' + ex.Message).Status(404);     //DEU ERRO
        end;
      finally
          FreeAndNil(dm);
      end;
end;

end.
