unit Controllers.Material;

interface

uses Horse,
     System.JSON,
     System.SysUtils,
     DM;

     procedure RegistrarRotas;
     procedure ListarMaterial(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
     procedure InsertMaterial(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
     procedure DeleteMaterial(Req: THorseRequest; Res: THorseResponse; Next: Tproc);

     procedure ListarMaterialClient(Req: THorseRequest; Res: THorseResponse; Next: Tproc);

implementation

procedure RegistrarRotas;
begin
    // Configurações de endpoints do Horse
    THorse.Get('/listarmaterial',  ListarMaterial);
    THorse.Post('/postmaterial',  InsertMaterial);
    THorse.Delete('/deletematerial/:id_material',  DeleteMaterial);
    THorse.Post('/listarmaterialclient',  ListarMaterialClient);

end;

procedure ListarMaterial(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
begin
      try
          dm  := TDtm.Create(nil);
          Res.Send(dm.ListarMaterial()).Status(200);
      finally
          FreeAndNil(dm);
      end;
end;

procedure InsertMaterial(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  body: TJSONObject;
  name: string;
begin
      try
        try
            dm          := TDtm.Create(nil);
            body        := Req.Body<TJSONObject>;

            name      := body.GetValue<string>('name', '');

            Res.Send(dm.InsertMaterial(name)).Status(201);

        except
          on ex:exception do
            Res.Send('Houve  um erro:' + ex.Message).Status(502);     //DEU ERRO
        end;
      finally
          FreeAndNil(dm);
      end;
end;


// Função para deletar um registro específico
procedure DeleteMaterial(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  id_material: integer;
  Json_ret: TJSONObject;
begin
     try
        try
            dm       := TDtm.Create(nil);

            try
               id_material  := Req.Params.Items['id_material'].ToInteger;
            except
               id_material := 0;
            end;

            Json_ret := dm.DeleteMaterial(id_material);


            Res.Send('Material Id  ' + inttostr(id_material) + '  Foi Excluido!').Status(200);

        except
          on ex:exception do
            Res.Send('Ops! ' + ex.Message).Status(404);     //DEU ERRO
        end;
      finally
          FreeAndNil(dm);
      end;
end;


procedure ListarMaterialClient(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  body, Json_ret: TJSONObject;
  id_client, id_origin, id_destination: integer;
begin
      try
          dm  := TDtm.Create(nil);
          body     := Req.Body<TJSONObject>;
          id_client := body.GetValue<integer>('id_client', 0);
          id_origin := body.GetValue<integer>('id_origin', 0);
          id_destination := body.GetValue<integer>('id_destination', 0);

            Json_ret := dm.ListarMaterialClient(id_client, id_origin, id_destination);
            Res.Send<TJsonObject>(Json_ret).Status(201);

      finally
          FreeAndNil(dm);
      end;
end;

end.
