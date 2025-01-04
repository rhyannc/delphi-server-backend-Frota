unit Controllers.Points;

interface

uses Horse,
     System.JSON,
     System.SysUtils,
     DM;

     procedure RegistrarRotas;
     procedure ListarPoints(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
     procedure InsertPoint(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
     procedure UpdatePoint(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
     procedure DeletePoint(Req: THorseRequest; Res: THorseResponse; Next: Tproc);

     procedure ListarOriginClient(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
     procedure ListarDestineClient(Req: THorseRequest; Res: THorseResponse; Next: Tproc);

implementation

procedure RegistrarRotas;
begin
    // Configurações de endpoints do Horse
    THorse.Get('/listarpoints',  ListarPoints);
    THorse.Post('/postpoint',  InsertPoint);
    THorse.Put('/updatepoint', UpdatePoint);
    THorse.Delete('/deletepoint/:id_point',  DeletePoint);

    THorse.Post('/listaroriginclient',  ListarOriginClient);
    THorse.Post('/listardestineclient',  ListarDestineClient);

end;

procedure ListarPoints(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
begin
      try
          dm  := TDtm.Create(nil);
          Res.Send(dm.ListarPoints()).Status(200);
      finally
          FreeAndNil(dm);
      end;
end;

procedure InsertPoint(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  body: TJSONObject;
  name, description, city, addres: string;
begin
      try
        try
            dm          := TDtm.Create(nil);
            body        := Req.Body<TJSONObject>;

            name         := body.GetValue<string>('name', '');
            description  := body.GetValue<string>('description', '');
            city         := body.GetValue<string>('city', '');
            addres       := body.GetValue<string>('addres', '');

            Res.Send(dm.InsertPoint(name, description, city, addres)).Status(201);

        except
          on ex:exception do
            Res.Send('Houve  um erro:' + ex.Message).Status(502);     //DEU ERRO
        end;
      finally
          FreeAndNil(dm);
      end;
end;

// Função para Atualizar um registro específico
procedure UpdatePoint(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  body, Json_ret: TJSONObject;
  name, city, addres: string;
  id_point: integer;
begin
     try
        try
            dm       := TDtm.Create(nil);

            body     := Req.Body<TJSONObject>;
            id_point := body.GetValue<integer>('id_point', 0);
            name     := body.GetValue<string>('name', '');
            city     := body.GetValue<string>('city', '');
            addres     := body.GetValue<string>('addres', '');

            Json_ret := dm.UpdatePoint(id_point, name, city, addres);
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
procedure DeletePoint(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  id_point: integer;
  Json_ret: TJSONObject;
begin
     try
        try
            dm       := TDtm.Create(nil);

            try
               id_point  := Req.Params.Items['id_point'].ToInteger;
            except
               id_point := 0;
            end;

            Json_ret := dm.DeletePoint(id_point);


            Res.Send('Point Id  ' + inttostr(id_point) + '  Foi Excluido!').Status(200);

        except
          on ex:exception do
            Res.Send('Ops! ' + ex.Message).Status(404);     //DEU ERRO
        end;
      finally
          FreeAndNil(dm);
      end;
end;



procedure ListarOriginClient(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  body, Json_ret: TJSONObject;
  id_client: integer;
begin
      try
          dm  := TDtm.Create(nil);
          body     := Req.Body<TJSONObject>;
          id_client := body.GetValue<integer>('id_client', 0);

            Json_ret := dm.ListarOriginClient(id_client);
            Res.Send<TJsonObject>(Json_ret).Status(201);

      finally
          FreeAndNil(dm);
      end;
end;

procedure ListarDestineClient(Req: THorseRequest; Res: THorseResponse; Next: Tproc);
var
  dm:TDtm;
  body, Json_ret: TJSONObject;
  id_client, id_origin: integer;
begin
      try
          dm  := TDtm.Create(nil);
          body     := Req.Body<TJSONObject>;
          id_client := body.GetValue<integer>('id_client', 0);
          id_origin := body.GetValue<integer>('id_origin', 0);

            Json_ret := dm.ListarDestineClient(id_client, id_origin);
            Res.Send<TJsonObject>(Json_ret).Status(201);

      finally
          FreeAndNil(dm);
      end;
end;

end.
