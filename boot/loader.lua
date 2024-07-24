-- we use this so we know where we are
-- the parent of this dir should be the root of the boot drive
local parentDir = debug.getinfo(1).source:match("@?(.*/)")
local bootFile = ""
local function boot(kernel,timeout,name,...)
	term.setCursorPos(1,2)
	print("Hit RETURN or wait "..timeout.." seconds to load "..name..".")	
	parallel.waitForAny(function()
		while true do
			local _, key = os.pullEvent("key")
			if key == keys.enter then
				break
			end
		end
	end,
	function()
		sleep(tonumber(timeout))
	end)
	print("")
	local success, response = pcall(os.run,{},kernel,...)
	if not success then
		printError(response)
		while true do
			sleep() 
		end
	end
end
local function startBoot(bootDrive)
	term.write("L")
	if not fs.find(parentDir.."/map.json") then
		while true do
			sleep()
		end
	end
	if parentDir:sub(1,#bootDrive) ~= bootDrive then
		term.write("?") --something isnt right
		while true do
			sleep()
		end
	end
	local file = fs.open(parentDir.."map.json", "r")
	if file == nil then
		term.write("-") --file doesnt exist
		while true do
			sleep()
		end
	end
	local descriptor = textutils.unserialiseJSON(file.readAll())
	if descriptor == nil or descriptor.bootfile == nil or descriptor.args == nil or descriptor.timeout == nil or descriptor.name == nil then
		term.write("-") --json is nil
		while true do
			sleep()
		end
	end
	file.close()
	term.write("O")
	boot(bootDrive..descriptor.bootfile,descriptor.timeout,descriptor.name,table.unpack(descriptor.args))
end
if #{...} ~= 0 then
	startBoot(...)
else
	while true do
		sleep()
	end
end