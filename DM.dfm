object Dtm: TDtm
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 204
  Width = 333
  object Conn: TFDConnection
    Params.Strings = (
      'DriverID=SQLite')
    LoginPrompt = False
    BeforeConnect = ConnBeforeConnect
    Left = 144
    Top = 72
  end
end
