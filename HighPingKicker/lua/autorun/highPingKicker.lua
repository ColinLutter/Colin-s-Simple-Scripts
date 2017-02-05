local rgb = Color

--CONFIG
local PingGrenze = 200
local ToleranzGrenze = 100
local CheckIntervall = 25 -- In Sekunden
local MaxWarns = 4
--CONFIG ENDE!

if (SERVER) then

  util.AddNetworkString("hk_WarnChatText")

  hook.Add("Initialize", "init_hpKicker", function()
    MsgC(rgb(22, 160, 133), "[HPKicker] Initalisiert!\n")
  end)

  local pM = FindMetaTable("Player")

    function pM:GetPingWarns()
      if !self.pingWarns then
        self.pingWarns = 0;
        self.totalWarns = 0;
      end;

      return self.pingWarns, self.totalWarns
    end;

    function pM:GivePingWarn()
      if !self.pingWarns then
        self.pingWarns = 0;
        self.totalWarns = 0;
      end;

      if (self.pingWarns > (MaxWarns - 1)) then
        self:Kick( "High Ping Kick (PING: "..self:Ping()..")" )
      end;

      self.totalWarns = self.totalWarns + 1
      self.pingWarns = self.pingWarns + 1

      net.Start("hk_WarnChatText")
        net.WriteBool(false)
        net.WriteInt(self.pingWarns, 3)
      net.Send(self)
    end;

    function pM:SetPingWarn( s )
      if !self.pingWarns then
        self.pingWarns = 0;
        self.totalWarns = 0;
      end;

      self.pingWarns = s
    end;

    function pM:TakePingWarn()
      if !self.pingWarns then
        self.pingWarns = 0;
      end;

      if (self.pingWarns > 0) then
        self.pingWarns = self.pingWarns - 1
        net.Start("hk_WarnChatText")
          net.WriteBool(true)
          net.WriteInt(self.pingWarns, 3)
        net.Send(self)
      else
        self.pingWarns = 0;
      end;
    end;

  timer.Create("hpKicker_checkIntervall", CheckIntervall, 0, function()
    for k, v in pairs(player.GetAll()) do
      local ping = v:Ping()

      if (v:GetPingWarns() > (MaxWarns - 1)) then
        v:Kick( "High Ping Kick (PING: "..ping..")" )
      end;

      if (ping > PingGrenze) then
        v:GivePingWarn()
          print(v:Nick().." Warns + 1")
          --t[v:Nick()] = v:GetPingWarns();
      elseif (ping < ToleranzGrenze ) then
        v:TakePingWarn()
      end
    end;
  end)

  concommand.Add("hpkicker_totalwarns", function(pl, cmd, args)
    if !(#args > 0) then
      return print("Es wurde kein Spieler angegeben.")
    end;
    local target;
    for k, v in pairs(player.GetAll()) do
      if ( string.lower(v:Nick()) == string.lower(args[1]) ) then
        target = v;
      end;
    end;

    if !target then return print("Es wurde kein VALIDER Spieler angegeben") end
    if !target.totalWarns then target.totalWarns = 0; end

    print("Warns:", target.pingWarns)
    print("Total:", target.totalWarns)
  end)

  concommand.Add("hpkicker_setwarns", function(pl, cmd, args)
    if !(#args > 0) then
      return print("hpkicker_setwarns [Spieler] [Anzahl]")
    end;

    local target;
    for k, v in pairs(player.GetAll()) do
      if ( string.lower(v:Nick()) == string.lower(args[1]) ) then
        target = v;
      end;
    end;

    local amount = tonumber(args[2])

    if !target then return print("Es wurde kein VALIDER Spieler angegeben.") end
    if !amount then return print("Es wurde keine VALIDE Zahl angegeben.") end

    target:SetPingWarn( amount )
  end)
else
  net.Receive("hk_WarnChatText", function(len)
    local bool = net.ReadBool()
    local int = net.ReadInt(3)
    if !bool then
      chat.AddText(rgb(231, 76, 60), "Dein Ping ist zu Hoch! Du hast nun "..int.." Ping-Warn(s). (Ping: "..tostring(LocalPlayer():Ping())..")")
      --print("Dein Ping ist zu Hoch! Du hast nun "..int.." Ping-Warns. (Ping: "..tostring(LocalPlayer():Ping())..")")
    else
      chat.AddText(rgb(230, 126, 34), "Da dein Ping wieder im grünen Bereich ist, wird dir ein Warn erlassen! Du hast noch "..int.." weitere(n) Ping-Warns. (Ping: "..tostring(LocalPlayer():Ping())..")")
      --print("Da dein Ping wieder im grünen Bereich ist, wird dir ein Warn erlassen! Du hast noch "..int.." weitere(n) Ping-Warns. (Ping: "..tostring(LocalPlayer():Ping())..")")
    end;
  end)
end;
