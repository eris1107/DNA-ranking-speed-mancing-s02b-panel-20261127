-- DNA Tempo S02: observed fishing animation ranking. Separate from R8. No HTTP or scoring.
-- Animation matched 10 actual catches near and far on one test account, not universally verified.
local Players=game:GetService('Players')
local gui=Players.LocalPlayer:WaitForChild('PlayerGui')
assert(not gui:FindFirstChild('DNA_TEMPO_S02'),'Daftar tempo sudah terbuka')
local screen=Instance.new('ScreenGui');screen.Name='DNA_TEMPO_S02';screen.ResetOnSpawn=false;screen.Parent=gui
local frame=Instance.new('Frame');frame.Size=UDim2.fromOffset(520,390);frame.Position=UDim2.new(0,15,0,90)
frame.BackgroundColor3=Color3.fromRGB(22,28,39);frame.Parent=screen
local function button(text,x,y,w)
 local b=Instance.new('TextButton');b.Text=text;b.Size=UDim2.fromOffset(w,30);b.Position=UDim2.fromOffset(x,y);b.TextSize=13;b.Parent=frame;return b
end
local minimize=button('Tempo Sesi | minimize',5,5,330)
local reset=button('Reset data',340,5,100)
local close=button('Tutup',445,5,70)
local note=Instance.new('TextLabel');note.Size=UDim2.new(1,-14,0,62);note.Position=UDim2.fromOffset(7,40)
note.BackgroundTransparency=1;note.TextColor3=Color3.fromRGB(225,235,245);note.TextSize=13;note.TextWrapped=true
note.Text='Peringkat sepanjang sesi, tidak hilang setelah 30 detik. Minimal 10 kejadian dan 9 selang valid. Data lama tetap terlihat saat pemain jeda/keluar. Bukan bukti script.';note.Parent=frame
local scroll=Instance.new('ScrollingFrame');scroll.Size=UDim2.new(1,-14,1,-115);scroll.Position=UDim2.fromOffset(7,108)
scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0;scroll.ScrollBarThickness=12;scroll.ScrollBarImageColor3=Color3.fromRGB(100,200,255);scroll.AutomaticCanvasSize=Enum.AutomaticSize.None;scroll.ScrollingDirection=Enum.ScrollingDirection.Y;scroll.ScrollingEnabled=true;scroll.Active=true;scroll.CanvasSize=UDim2.new();scroll.Parent=frame
local output=Instance.new('TextLabel');output.Size=UDim2.new(1,-20,0,1);output.AutomaticSize=Enum.AutomaticSize.None
output.BackgroundTransparency=1;output.TextColor3=Color3.fromRGB(230,240,250);output.Font=Enum.Font.Code;output.TextSize=13
output.TextWrapped=true;output.TextXAlignment=Enum.TextXAlignment.Left;output.TextYAlignment=Enum.TextYAlignment.Top;output.Parent=scroll
local TextService=game:GetService('TextService')
local footer=Instance.new('TextLabel');footer.BackgroundTransparency=1;footer.TextColor3=Color3.fromRGB(130,215,255)
footer.Text='Scroll di dalam daftar untuk melihat peringkat berikutnya';footer.TextSize=12;footer.TextWrapped=true;footer.Parent=frame
local function fitPanel()
 local camera=workspace.CurrentCamera
 local viewport=camera and camera.ViewportSize or Vector2.new(800,600)
 local width=math.max(260,math.min(640,viewport.X-30))
 local height=math.max(200,math.min(620,viewport.Y-110))
 frame.Position=UDim2.fromOffset(15,10);frame.Size=UDim2.fromOffset(width,height)
 minimize.Size=UDim2.new(1,-190,0,30)
 reset.Position=UDim2.new(1,-175,0,5);reset.Size=UDim2.fromOffset(100,30)
 close.Position=UDim2.new(1,-70,0,5);close.Size=UDim2.fromOffset(65,30)
 local noteHeight=math.ceil(TextService:GetTextSize(note.Text,note.TextSize,note.Font,Vector2.new(width-14,1000000)).Y)+10
 note.Size=UDim2.new(1,-14,0,noteHeight)
 local top=40+noteHeight+6
 scroll.Position=UDim2.fromOffset(7,top);scroll.Size=UDim2.new(1,-14,1,-top-35)
 footer.Position=UDim2.new(0,7,1,-32);footer.Size=UDim2.new(1,-14,0,30)
 -- Explicit measurement avoids relying on AutomaticCanvasSize + AutomaticSize interaction.
 local textWidth=math.max(80,width-34)
 local textHeight=math.ceil(TextService:GetTextSize(output.Text,output.TextSize,output.Font,Vector2.new(textWidth,1000000)).Y)+30
 output.Size=UDim2.new(1,-20,0,textHeight)
 scroll.CanvasSize=UDim2.fromOffset(0,textHeight)
 local oldY=scroll.CanvasPosition.Y
 scroll.CanvasPosition=Vector2.new(0,math.max(0,math.min(oldY,textHeight-math.max(1,height-top-35))))
end
local restore=Instance.new('TextButton');restore.Size=UDim2.fromOffset(145,35);restore.Position=frame.Position;restore.Text='Buka Tempo Mancing';restore.Visible=false;restore.Parent=screen
minimize.Activated:Connect(function()frame.Visible=false;restore.Visible=true end)
restore.Activated:Connect(function()frame.Visible=true;restore.Visible=false end)
local active=true;local states={};local globalLinks={};local animationId='117319000848286'
local function disconnect(list)for _,c in ipairs(list)do c:Disconnect()end end
local function newSegment(state)
 state.segmentCount=0;state.previous=nil
end
local function median(values)
 if #values==0 then return nil end
 local sorted={};for _,v in ipairs(values)do table.insert(sorted,v)end;table.sort(sorted)
 local mid=math.floor(#sorted/2)+1
 if #sorted%2==1 then return sorted[mid]end
 return (sorted[mid-1]+sorted[mid])/2
end
local function unavailable(state)
 if state.available then state.breaks=state.breaks+1;newSegment(state)end
 state.available=false;state.animator=nil
end
local function bindCharacter(state,character)
 disconnect(state.characterLinks);state.characterLinks={}
 if state.available then state.breaks=state.breaks+1 end
 newSegment(state);state.available=false;state.animator=nil;state.character=character
 local function attach(animator)
  if not active or state.character~=character or state.animator==animator then return end
  if state.animationLink then state.animationLink:Disconnect()end
  if state.available then state.breaks=state.breaks+1;newSegment(state)end
  state.animator=animator;state.available=true
  state.animationLink=animator.AnimationPlayed:Connect(function(track)
   if not active or not state.available or state.animator~=animator then return end
   local anim=track.Animation;local id=anim and anim.AnimationId:match('%d+')
   if id~=animationId then return end
   local now=os.clock();state.total=state.total+1;state.segmentCount=state.segmentCount+1
   if state.previous then
    table.insert(state.gaps,now-state.previous)
    state.medianDirty=true
   end
   state.previous=now;state.last=now
  end)
 end
 for _,o in ipairs(character:GetDescendants())do if o:IsA('Animator')then attach(o);break end end
 table.insert(state.characterLinks,character.DescendantAdded:Connect(function(o)if o:IsA('Animator')then attach(o)end end))
 table.insert(state.characterLinks,character.AncestryChanged:Connect(function()
  if not character:IsDescendantOf(workspace)then unavailable(state)end
 end))
end
local function add(player)
 local state=states[player.UserId]
 if state and state.present then return end
 if state then
  state.player=player;state.present=true;state.links={};state.characterLinks={}
 else
  state={player=player,present=true,total=0,segmentCount=0,gaps={},breaks=0,available=false,characterLinks={},links={},medianDirty=true}
 end
 states[player.UserId]=state
 table.insert(state.links,player.CharacterAdded:Connect(function(c)bindCharacter(state,c)end))
 table.insert(state.links,player.CharacterRemoving:Connect(function()unavailable(state)end))
 if player.Character then bindCharacter(state,player.Character)end
end
for _,p in ipairs(Players:GetPlayers())do add(p)end
table.insert(globalLinks,Players.PlayerAdded:Connect(add))
table.insert(globalLinks,Players.PlayerRemoving:Connect(function(p)
 local s=states[p.UserId];if not s then return end
 disconnect(s.links);disconnect(s.characterLinks);if s.animationLink then s.animationLink:Disconnect()end
 unavailable(s);s.present=false;s.character=nil;s.links={};s.characterLinks={}
end))
local function render()
 local ranked,pending={},{};local now=os.clock()
 for _,s in pairs(states)do
  local valid=s.character and s.character:IsDescendantOf(workspace) and s.animator and s.animator:IsDescendantOf(s.character)
  if s.available and not valid then unavailable(s)end
  -- Reacquire an existing animator after streaming/reappearance without requiring respawn.
  if s.present and not s.available and s.player.Character and s.player.Character:IsDescendantOf(workspace)then
   local a=s.player.Character:FindFirstChildWhichIsA('Animator',true)
   if a then bindCharacter(s,s.player.Character)end
  end
  if s.medianDirty then s.cachedMedian=median(s.gaps);s.medianDirty=false end
  local m=s.cachedMedian
  local row={s=s,m=m}
  if s.total>=10 and #s.gaps>=9 and m and m>0 then table.insert(ranked,row)
  else table.insert(pending,row)end
 end
 table.sort(ranked,function(a,b)if a.m==b.m then return a.s.player.Name<b.s.player.Name end;return a.m<b.m end)
 table.sort(pending,function(a,b)return a.s.player.Name<b.s.player.Name end)
 local lines={'URUTAN TERCEPAT | median seluruh selang sesi',''}
 for i,r in ipairs(ranked)do
  local s=r.s
  local status=not s.present and 'keluar server' or not s.available and 'pengamatan terputus' or s.last and now-s.last>30 and 'tidak ada kejadian >30 dtk' or 'kejadian terbaru tersedia'
  table.insert(lines,string.format('%d. %s (@%s)\n   %.3f dtk/siklus | %.1f siklus/menit* | total %d | selang %d | putus %d\n   %s',i,s.player.DisplayName,s.player.Name,r.m,60/r.m,s.total,#s.gaps,s.breaks,status))
 end
 if #ranked==0 then table.insert(lines,'Menunggu minimal 10 kejadian dan 9 selang valid per pemain.')end
 table.insert(lines,'\nBELUM MASUK PERINGKAT')
 for _,r in ipairs(pending)do
  local s=r.s;local reason='data belum cukup '..s.total..'/10; selang '..#s.gaps..'/9'
  if not s.present then reason=reason..'; keluar server' elseif not s.available then reason=reason..'; pengamatan terputus' end
  table.insert(lines,s.player.DisplayName..' (@'..s.player.Name..') | '..reason..' | total '..s.total..' | putus '..s.breaks)
 end
 table.insert(lines,'\n*60 / median selang, bukan jumlah tangkapan aktual satu menit. Jeda saat karakter tetap terpantau ikut memengaruhi tempo. Selang melintasi putus pengamatan tidak dihitung. Data yang tidak diterima tanpa putus karakter bisa terlewat. Data sesi tidak disimpan ke disk.')
 output.Text=table.concat(lines,'\n')
 fitPanel()
end
reset.Activated:Connect(function()
 for _,s in pairs(states)do s.total=0;s.breaks=0;s.last=nil;s.gaps={};s.cachedMedian=nil;s.medianDirty=true;newSegment(s)end
 render()
end)
local function stop()
 if not active then return end;active=false;disconnect(globalLinks)
 for _,s in pairs(states)do disconnect(s.links);disconnect(s.characterLinks);if s.animationLink then s.animationLink:Disconnect()end end
end
close.Activated:Connect(function()screen:Destroy()end)
screen.Destroying:Connect(stop)
task.spawn(function()while active do render();task.wait(1)end end)
