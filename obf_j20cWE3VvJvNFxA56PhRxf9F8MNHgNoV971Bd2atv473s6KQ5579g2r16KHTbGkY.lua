--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.6) ~  Much Love, Ferib 

]]--

local StrToNumber = tonumber;
local Byte = string.byte;
local Char = string.char;
local Sub = string.sub;
local Subg = string.gsub;
local Rep = string.rep;
local Concat = table.concat;
local Insert = table.insert;
local LDExp = math.ldexp;
local GetFEnv = getfenv or function()
	return _ENV;
end;
local Setmetatable = setmetatable;
local PCall = pcall;
local Select = select;
local Unpack = unpack or table.unpack;
local ToNumber = tonumber;
local function VMCall(ByteString, vmenv, ...)
	local DIP = 1;
	local repeatNext;
	ByteString = Subg(Sub(ByteString, 5), "..", function(byte)
		if (Byte(byte, 2) == 79) then
			repeatNext = StrToNumber(Sub(byte, 1, 1));
			return "";
		else
			local a = Char(StrToNumber(byte, 16));
			if repeatNext then
				local b = Rep(a, repeatNext);
				repeatNext = nil;
				return b;
			else
				return a;
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local FlatIdent_95CAC = 0;
			local Res;
			while true do
				if (FlatIdent_95CAC == 0) then
					Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
					return Res - (Res % 1);
				end
			end
		else
			local Plc = 2 ^ (Start - 1);
			return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
		end
	end
	local function gBits8()
		local a = Byte(ByteString, DIP, DIP);
		DIP = DIP + 1;
		return a;
	end
	local function gBits16()
		local a, b = Byte(ByteString, DIP, DIP + 2);
		DIP = DIP + 2;
		return (b * 256) + a;
	end
	local function gBits32()
		local a, b, c, d = Byte(ByteString, DIP, DIP + 3);
		DIP = DIP + 4;
		return (d * 16777216) + (c * 65536) + (b * 256) + a;
	end
	local function gFloat()
		local FlatIdent_76979 = 0;
		local Left;
		local Right;
		local IsNormal;
		local Mantissa;
		local Exponent;
		local Sign;
		while true do
			if (FlatIdent_76979 == 0) then
				Left = gBits32();
				Right = gBits32();
				FlatIdent_76979 = 1;
			end
			if (FlatIdent_76979 == 3) then
				if (Exponent == 0) then
					if (Mantissa == 0) then
						return Sign * 0;
					else
						Exponent = 1;
						IsNormal = 0;
					end
				elseif (Exponent == 2047) then
					return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
				end
				return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
			end
			if (FlatIdent_76979 == 2) then
				Exponent = gBit(Right, 21, 31);
				Sign = ((gBit(Right, 32) == 1) and -1) or 1;
				FlatIdent_76979 = 3;
			end
			if (FlatIdent_76979 == 1) then
				IsNormal = 1;
				Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
				FlatIdent_76979 = 2;
			end
		end
	end
	local function gString(Len)
		local Str;
		if not Len then
			local FlatIdent_2FBEB = 0;
			while true do
				if (FlatIdent_2FBEB == 0) then
					Len = gBits32();
					if (Len == 0) then
						return "";
					end
					break;
				end
			end
		end
		Str = Sub(ByteString, DIP, (DIP + Len) - 1);
		DIP = DIP + Len;
		local FStr = {};
		for Idx = 1, #Str do
			FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
		end
		return Concat(FStr);
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local Instrs = {};
		local Functions = {};
		local Lines = {};
		local Chunk = {Instrs,Functions,nil,Lines};
		local ConstCount = gBits32();
		local Consts = {};
		for Idx = 1, ConstCount do
			local FlatIdent_8D83D = 0;
			local Type;
			local Cons;
			while true do
				if (FlatIdent_8D83D == 1) then
					if (Type == 1) then
						Cons = gBits8() ~= 0;
					elseif (Type == 2) then
						Cons = gFloat();
					elseif (Type == 3) then
						Cons = gString();
					end
					Consts[Idx] = Cons;
					break;
				end
				if (FlatIdent_8D83D == 0) then
					Type = gBits8();
					Cons = nil;
					FlatIdent_8D83D = 1;
				end
			end
		end
		Chunk[3] = gBits8();
		for Idx = 1, gBits32() do
			local FlatIdent_44839 = 0;
			local Descriptor;
			while true do
				if (FlatIdent_44839 == 0) then
					Descriptor = gBits8();
					if (gBit(Descriptor, 1, 1) == 0) then
						local FlatIdent_25011 = 0;
						local Type;
						local Mask;
						local Inst;
						while true do
							if (FlatIdent_25011 == 2) then
								if (gBit(Mask, 1, 1) == 1) then
									Inst[2] = Consts[Inst[2]];
								end
								if (gBit(Mask, 2, 2) == 1) then
									Inst[3] = Consts[Inst[3]];
								end
								FlatIdent_25011 = 3;
							end
							if (FlatIdent_25011 == 0) then
								Type = gBit(Descriptor, 2, 3);
								Mask = gBit(Descriptor, 4, 6);
								FlatIdent_25011 = 1;
							end
							if (FlatIdent_25011 == 3) then
								if (gBit(Mask, 3, 3) == 1) then
									Inst[4] = Consts[Inst[4]];
								end
								Instrs[Idx] = Inst;
								break;
							end
							if (FlatIdent_25011 == 1) then
								Inst = {gBits16(),gBits16(),nil,nil};
								if (Type == 0) then
									Inst[3] = gBits16();
									Inst[4] = gBits16();
								elseif (Type == 1) then
									Inst[3] = gBits32();
								elseif (Type == 2) then
									Inst[3] = gBits32() - (2 ^ 16);
								elseif (Type == 3) then
									Inst[3] = gBits32() - (2 ^ 16);
									Inst[4] = gBits16();
								end
								FlatIdent_25011 = 2;
							end
						end
					end
					break;
				end
			end
		end
		for Idx = 1, gBits32() do
			Functions[Idx - 1] = Deserialize();
		end
		return Chunk;
	end
	local function Wrap(Chunk, Upvalues, Env)
		local Instr = Chunk[1];
		local Proto = Chunk[2];
		local Params = Chunk[3];
		return function(...)
			local Instr = Instr;
			local Proto = Proto;
			local Params = Params;
			local _R = _R;
			local VIP = 1;
			local Top = -1;
			local Vararg = {};
			local Args = {...};
			local PCount = Select("#", ...) - 1;
			local Lupvals = {};
			local Stk = {};
			for Idx = 0, PCount do
				if (Idx >= Params) then
					Vararg[Idx - Params] = Args[Idx + 1];
				else
					Stk[Idx] = Args[Idx + 1];
				end
			end
			local Varargsz = (PCount - Params) + 1;
			local Inst;
			local Enum;
			while true do
				Inst = Instr[VIP];
				Enum = Inst[1];
				if (Enum <= 32) then
					if (Enum <= 15) then
						if (Enum <= 7) then
							if (Enum <= 3) then
								if (Enum <= 1) then
									if (Enum > 0) then
										Stk[Inst[2]][Stk[Inst[3]]] = Stk[Inst[4]];
									else
										local FlatIdent_51F42 = 0;
										local Edx;
										local Results;
										local Limit;
										local B;
										local A;
										while true do
											if (FlatIdent_51F42 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												FlatIdent_51F42 = 3;
											end
											if (FlatIdent_51F42 == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
												FlatIdent_51F42 = 7;
											end
											if (FlatIdent_51F42 == 0) then
												Edx = nil;
												Results, Limit = nil;
												B = nil;
												A = nil;
												FlatIdent_51F42 = 1;
											end
											if (FlatIdent_51F42 == 4) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_51F42 = 5;
											end
											if (3 == FlatIdent_51F42) then
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_51F42 = 4;
											end
											if (5 == FlatIdent_51F42) then
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
												end
												FlatIdent_51F42 = 6;
											end
											if (FlatIdent_51F42 == 1) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_51F42 = 2;
											end
											if (FlatIdent_51F42 == 8) then
												Inst = Instr[VIP];
												do
													return;
												end
												break;
											end
											if (FlatIdent_51F42 == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]]();
												VIP = VIP + 1;
												FlatIdent_51F42 = 8;
											end
										end
									end
								elseif (Enum == 2) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								else
									Stk[Inst[2]][Inst[3]] = Inst[4];
								end
							elseif (Enum <= 5) then
								if (Enum > 4) then
									Stk[Inst[2]]();
								else
									local A = Inst[2];
									local C = Inst[4];
									local CB = A + 2;
									local Result = {Stk[A](Stk[A + 1], Stk[CB])};
									for Idx = 1, C do
										Stk[CB + Idx] = Result[Idx];
									end
									local R = Result[1];
									if R then
										local FlatIdent_33EA4 = 0;
										while true do
											if (FlatIdent_33EA4 == 0) then
												Stk[CB] = R;
												VIP = Inst[3];
												break;
											end
										end
									else
										VIP = VIP + 1;
									end
								end
							elseif (Enum == 6) then
								local Edx;
								local Results;
								local B;
								local A;
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results = {Stk[A](Stk[A + 1])};
								Edx = 0;
								for Idx = A, Inst[4] do
									local FlatIdent_25DF3 = 0;
									while true do
										if (FlatIdent_25DF3 == 0) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							elseif Stk[Inst[2]] then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 11) then
							if (Enum <= 9) then
								if (Enum > 8) then
									do
										return;
									end
								else
									local FlatIdent_5BA5E = 0;
									local Edx;
									local Results;
									local Limit;
									local B;
									local A;
									while true do
										if (FlatIdent_5BA5E == 0) then
											Edx = nil;
											Results, Limit = nil;
											B = nil;
											A = nil;
											FlatIdent_5BA5E = 1;
										end
										if (FlatIdent_5BA5E == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_5BA5E = 3;
										end
										if (FlatIdent_5BA5E == 5) then
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												local FlatIdent_D79D = 0;
												while true do
													if (0 == FlatIdent_D79D) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											FlatIdent_5BA5E = 6;
										end
										if (FlatIdent_5BA5E == 4) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_5BA5E = 5;
										end
										if (FlatIdent_5BA5E == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
											FlatIdent_5BA5E = 7;
										end
										if (FlatIdent_5BA5E == 3) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5BA5E = 4;
										end
										if (FlatIdent_5BA5E == 8) then
											Inst = Instr[VIP];
											do
												return;
											end
											break;
										end
										if (FlatIdent_5BA5E == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]]();
											VIP = VIP + 1;
											FlatIdent_5BA5E = 8;
										end
										if (FlatIdent_5BA5E == 1) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_5BA5E = 2;
										end
									end
								end
							elseif (Enum == 10) then
								local A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 13) then
							if (Enum > 12) then
								local A = Inst[2];
								Stk[A] = Stk[A]();
							else
								local B;
								local A;
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
							end
						elseif (Enum == 14) then
							if not Stk[Inst[2]] then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						else
							local NewProto = Proto[Inst[3]];
							local NewUvals;
							local Indexes = {};
							NewUvals = Setmetatable({}, {__index=function(_, Key)
								local FlatIdent_40B41 = 0;
								local Val;
								while true do
									if (FlatIdent_40B41 == 0) then
										Val = Indexes[Key];
										return Val[1][Val[2]];
									end
								end
							end,__newindex=function(_, Key, Value)
								local Val = Indexes[Key];
								Val[1][Val[2]] = Value;
							end});
							for Idx = 1, Inst[4] do
								VIP = VIP + 1;
								local Mvm = Instr[VIP];
								if (Mvm[1] == 24) then
									Indexes[Idx - 1] = {Stk,Mvm[3]};
								else
									Indexes[Idx - 1] = {Upvalues,Mvm[3]};
								end
								Lupvals[#Lupvals + 1] = Indexes;
							end
							Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
						end
					elseif (Enum <= 23) then
						if (Enum <= 19) then
							if (Enum <= 17) then
								if (Enum > 16) then
									local FlatIdent_AC2F = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_AC2F == 5) then
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_AC2F = 6;
										end
										if (FlatIdent_AC2F == 6) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											break;
										end
										if (FlatIdent_AC2F == 4) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_AC2F = 5;
										end
										if (0 == FlatIdent_AC2F) then
											B = nil;
											A = nil;
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_AC2F = 1;
										end
										if (FlatIdent_AC2F == 3) then
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_AC2F = 4;
										end
										if (1 == FlatIdent_AC2F) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_AC2F = 2;
										end
										if (FlatIdent_AC2F == 2) then
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_AC2F = 3;
										end
									end
								else
									local DIP;
									local NStk;
									local Upv;
									local List;
									local Cls;
									local B;
									local A;
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Cls = {};
									for Idx = 1, #Lupvals do
										List = Lupvals[Idx];
										for Idz = 0, #List do
											Upv = List[Idz];
											NStk = Upv[1];
											DIP = Upv[2];
											if ((NStk == Stk) and (DIP >= A)) then
												Cls[DIP] = NStk[DIP];
												Upv[1] = Cls;
											end
										end
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									do
										return;
									end
								end
							elseif (Enum > 18) then
								local FlatIdent_8BC55 = 0;
								local A;
								local Results;
								local Edx;
								while true do
									if (FlatIdent_8BC55 == 1) then
										Edx = 0;
										for Idx = A, Inst[4] do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										break;
									end
									if (FlatIdent_8BC55 == 0) then
										A = Inst[2];
										Results = {Stk[A](Stk[A + 1])};
										FlatIdent_8BC55 = 1;
									end
								end
							else
								local FlatIdent_8B336 = 0;
								local A;
								local Results;
								local Limit;
								local Edx;
								while true do
									if (FlatIdent_8B336 == 1) then
										Top = (Limit + A) - 1;
										Edx = 0;
										FlatIdent_8B336 = 2;
									end
									if (FlatIdent_8B336 == 0) then
										A = Inst[2];
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										FlatIdent_8B336 = 1;
									end
									if (FlatIdent_8B336 == 2) then
										for Idx = A, Top do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										break;
									end
								end
							end
						elseif (Enum <= 21) then
							if (Enum == 20) then
								local FlatIdent_6D9D2 = 0;
								local B;
								local K;
								while true do
									if (FlatIdent_6D9D2 == 0) then
										B = Inst[3];
										K = Stk[B];
										FlatIdent_6D9D2 = 1;
									end
									if (FlatIdent_6D9D2 == 1) then
										for Idx = B + 1, Inst[4] do
											K = K .. Stk[Idx];
										end
										Stk[Inst[2]] = K;
										break;
									end
								end
							else
								local B;
								local A;
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							end
						elseif (Enum == 22) then
							Stk[Inst[2]] = {};
						else
							local FlatIdent_28014 = 0;
							local A;
							while true do
								if (FlatIdent_28014 == 0) then
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									break;
								end
							end
						end
					elseif (Enum <= 27) then
						if (Enum <= 25) then
							if (Enum > 24) then
								local FlatIdent_21449 = 0;
								local Edx;
								local Results;
								local Limit;
								local B;
								local A;
								while true do
									if (FlatIdent_21449 == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_21449 = 7;
									end
									if (FlatIdent_21449 == 0) then
										Edx = nil;
										Results, Limit = nil;
										B = nil;
										A = nil;
										FlatIdent_21449 = 1;
									end
									if (FlatIdent_21449 == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_21449 = 5;
									end
									if (FlatIdent_21449 == 3) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										FlatIdent_21449 = 4;
									end
									if (FlatIdent_21449 == 7) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_21449 = 8;
									end
									if (FlatIdent_21449 == 1) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_21449 = 2;
									end
									if (FlatIdent_21449 == 10) then
										Stk[A](Unpack(Stk, A + 1, Top));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
										break;
									end
									if (FlatIdent_21449 == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_21449 = 3;
									end
									if (FlatIdent_21449 == 5) then
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										FlatIdent_21449 = 6;
									end
									if (FlatIdent_21449 == 8) then
										A = Inst[2];
										Results, Limit = _R(Stk[A](Stk[A + 1]));
										Top = (Limit + A) - 1;
										Edx = 0;
										FlatIdent_21449 = 9;
									end
									if (FlatIdent_21449 == 9) then
										for Idx = A, Top do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_21449 = 10;
									end
								end
							else
								Stk[Inst[2]] = Stk[Inst[3]];
							end
						elseif (Enum > 26) then
							local Edx;
							local Results, Limit;
							local B;
							local A;
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Inst[3];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
							Top = (Limit + A) - 1;
							Edx = 0;
							for Idx = A, Top do
								Edx = Edx + 1;
								Stk[Idx] = Results[Edx];
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A]();
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
						else
							local B;
							local A;
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
						end
					elseif (Enum <= 29) then
						if (Enum == 28) then
							local B;
							local A;
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
						else
							local Edx;
							local Results, Limit;
							local B;
							local A;
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Results, Limit = _R(Stk[A](Stk[A + 1]));
							Top = (Limit + A) - 1;
							Edx = 0;
							for Idx = A, Top do
								Edx = Edx + 1;
								Stk[Idx] = Results[Edx];
							end
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Top));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							VIP = Inst[3];
						end
					elseif (Enum <= 30) then
						for Idx = Inst[2], Inst[3] do
							Stk[Idx] = nil;
						end
					elseif (Enum == 31) then
						local FlatIdent_6679B = 0;
						local A;
						while true do
							if (FlatIdent_6679B == 0) then
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								break;
							end
						end
					else
						local A = Inst[2];
						local Results, Limit = _R(Stk[A](Stk[A + 1]));
						Top = (Limit + A) - 1;
						local Edx = 0;
						for Idx = A, Top do
							Edx = Edx + 1;
							Stk[Idx] = Results[Edx];
						end
					end
				elseif (Enum <= 49) then
					if (Enum <= 40) then
						if (Enum <= 36) then
							if (Enum <= 34) then
								if (Enum == 33) then
									Env[Inst[3]] = Stk[Inst[2]];
								else
									local FlatIdent_63AE4 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_63AE4 == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_63AE4 = 1;
										end
										if (FlatIdent_63AE4 == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_63AE4 = 2;
										end
										if (FlatIdent_63AE4 == 2) then
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_63AE4 = 3;
										end
										if (FlatIdent_63AE4 == 5) then
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_63AE4 = 6;
										end
										if (FlatIdent_63AE4 == 4) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_63AE4 = 5;
										end
										if (FlatIdent_63AE4 == 6) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											break;
										end
										if (FlatIdent_63AE4 == 3) then
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_63AE4 = 4;
										end
									end
								end
							elseif (Enum > 35) then
								if (Stk[Inst[2]] == Inst[4]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local B;
								local A;
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
							end
						elseif (Enum <= 38) then
							if (Enum == 37) then
								local FlatIdent_5D802 = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_5D802 == 0) then
										B = nil;
										A = nil;
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_5D802 = 1;
									end
									if (1 == FlatIdent_5D802) then
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										FlatIdent_5D802 = 2;
									end
									if (FlatIdent_5D802 == 5) then
										do
											return;
										end
										break;
									end
									if (FlatIdent_5D802 == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_5D802 = 5;
									end
									if (FlatIdent_5D802 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_5D802 = 4;
									end
									if (FlatIdent_5D802 == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_5D802 = 3;
									end
								end
							else
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							end
						elseif (Enum > 39) then
							Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
						else
							local FlatIdent_7126B = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_7126B == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									FlatIdent_7126B = 4;
								end
								if (FlatIdent_7126B == 1) then
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									FlatIdent_7126B = 2;
								end
								if (FlatIdent_7126B == 4) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_7126B = 5;
								end
								if (FlatIdent_7126B == 0) then
									B = nil;
									A = nil;
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_7126B = 1;
								end
								if (FlatIdent_7126B == 2) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									FlatIdent_7126B = 3;
								end
								if (5 == FlatIdent_7126B) then
									do
										return;
									end
									break;
								end
							end
						end
					elseif (Enum <= 44) then
						if (Enum <= 42) then
							if (Enum == 41) then
								local K;
								local B;
								local A;
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								B = Inst[3];
								K = Stk[B];
								for Idx = B + 1, Inst[4] do
									K = K .. Stk[Idx];
								end
								Stk[Inst[2]] = K;
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Env[Inst[3]] = Stk[Inst[2]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Env[Inst[3]] = Stk[Inst[2]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							else
								local FlatIdent_3ACCC = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_3ACCC == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										FlatIdent_3ACCC = 5;
									end
									if (FlatIdent_3ACCC == 8) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										FlatIdent_3ACCC = 9;
									end
									if (FlatIdent_3ACCC == 9) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										break;
									end
									if (FlatIdent_3ACCC == 0) then
										B = nil;
										A = nil;
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_3ACCC = 1;
									end
									if (FlatIdent_3ACCC == 5) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_3ACCC = 6;
									end
									if (2 == FlatIdent_3ACCC) then
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_3ACCC = 3;
									end
									if (FlatIdent_3ACCC == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										FlatIdent_3ACCC = 2;
									end
									if (7 == FlatIdent_3ACCC) then
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										FlatIdent_3ACCC = 8;
									end
									if (FlatIdent_3ACCC == 6) then
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_3ACCC = 7;
									end
									if (3 == FlatIdent_3ACCC) then
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_3ACCC = 4;
									end
								end
							end
						elseif (Enum > 43) then
							local B;
							local A;
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
						elseif (Inst[2] == Stk[Inst[4]]) then
							VIP = VIP + 1;
						else
							VIP = Inst[3];
						end
					elseif (Enum <= 46) then
						if (Enum > 45) then
							local A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Top));
						else
							local B;
							local A;
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
						end
					elseif (Enum <= 47) then
						local Edx;
						local Results, Limit;
						local B;
						local A;
						Stk[Inst[2]] = Env[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						B = Stk[Inst[3]];
						Stk[A + 1] = B;
						Stk[A] = B[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
						Top = (Limit + A) - 1;
						Edx = 0;
						for Idx = A, Top do
							Edx = Edx + 1;
							Stk[Idx] = Results[Edx];
						end
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]]();
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Env[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A](Stk[A + 1]);
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						VIP = Inst[3];
					elseif (Enum > 48) then
						Stk[Inst[2]] = Inst[3];
					else
						local B;
						local A;
						Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A](Unpack(Stk, A + 1, Inst[3]));
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						B = Stk[Inst[3]];
						Stk[A + 1] = B;
						Stk[A] = B[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = {};
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Inst[4];
					end
				elseif (Enum <= 57) then
					if (Enum <= 53) then
						if (Enum <= 51) then
							if (Enum == 50) then
								Stk[Inst[2]] = Env[Inst[3]];
							else
								local FlatIdent_1D164 = 0;
								local A;
								local Cls;
								while true do
									if (0 == FlatIdent_1D164) then
										A = Inst[2];
										Cls = {};
										FlatIdent_1D164 = 1;
									end
									if (FlatIdent_1D164 == 1) then
										for Idx = 1, #Lupvals do
											local FlatIdent_1E5DB = 0;
											local List;
											while true do
												if (FlatIdent_1E5DB == 0) then
													List = Lupvals[Idx];
													for Idz = 0, #List do
														local FlatIdent_1E4CB = 0;
														local Upv;
														local NStk;
														local DIP;
														while true do
															if (FlatIdent_1E4CB == 1) then
																DIP = Upv[2];
																if ((NStk == Stk) and (DIP >= A)) then
																	Cls[DIP] = NStk[DIP];
																	Upv[1] = Cls;
																end
																break;
															end
															if (FlatIdent_1E4CB == 0) then
																Upv = List[Idz];
																NStk = Upv[1];
																FlatIdent_1E4CB = 1;
															end
														end
													end
													break;
												end
											end
										end
										break;
									end
								end
							end
						elseif (Enum > 52) then
							local B;
							local A;
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
						else
							local A = Inst[2];
							local B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
						end
					elseif (Enum <= 55) then
						if (Enum > 54) then
							local FlatIdent_622B0 = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_622B0 == 4) then
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_622B0 = 5;
								end
								if (FlatIdent_622B0 == 3) then
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									FlatIdent_622B0 = 4;
								end
								if (FlatIdent_622B0 == 1) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_622B0 = 2;
								end
								if (5 == FlatIdent_622B0) then
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_622B0 = 6;
								end
								if (FlatIdent_622B0 == 2) then
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_622B0 = 3;
								end
								if (FlatIdent_622B0 == 0) then
									B = nil;
									A = nil;
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									FlatIdent_622B0 = 1;
								end
								if (6 == FlatIdent_622B0) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
									break;
								end
							end
						else
							local A = Inst[2];
							Stk[A](Stk[A + 1]);
						end
					elseif (Enum > 56) then
						Stk[Inst[2]] = Upvalues[Inst[3]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						for Idx = Inst[2], Inst[3] do
							Stk[Idx] = nil;
						end
						VIP = VIP + 1;
						Inst = Instr[VIP];
						VIP = Inst[3];
					else
						Stk[Inst[2]] = Upvalues[Inst[3]];
					end
				elseif (Enum <= 61) then
					if (Enum <= 59) then
						if (Enum == 58) then
							local B;
							local A;
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
						else
							local FlatIdent_71493 = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_71493 == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									FlatIdent_71493 = 4;
								end
								if (FlatIdent_71493 == 0) then
									B = nil;
									A = nil;
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									FlatIdent_71493 = 1;
								end
								if (FlatIdent_71493 == 4) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_71493 = 5;
								end
								if (FlatIdent_71493 == 5) then
									do
										return;
									end
									break;
								end
								if (FlatIdent_71493 == 2) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									FlatIdent_71493 = 3;
								end
								if (FlatIdent_71493 == 1) then
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									FlatIdent_71493 = 2;
								end
							end
						end
					elseif (Enum > 60) then
						local A = Inst[2];
						Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
					else
						local B;
						local A;
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						B = Stk[Inst[3]];
						Stk[A + 1] = B;
						Stk[A] = B[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Inst[3];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Env[Inst[3]] = Stk[Inst[2]];
					end
				elseif (Enum <= 63) then
					if (Enum > 62) then
						local B;
						local A;
						Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A](Unpack(Stk, A + 1, Inst[3]));
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						B = Stk[Inst[3]];
						Stk[A + 1] = B;
						Stk[A] = B[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = {};
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Inst[4];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						B = Stk[Inst[3]];
						Stk[A + 1] = B;
						Stk[A] = B[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = {};
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Inst[4];
					else
						local B;
						local A;
						A = Inst[2];
						B = Stk[Inst[3]];
						Stk[A + 1] = B;
						Stk[A] = B[Inst[4]];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]] = {};
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Inst[4];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Inst[4];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Inst[4];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						Stk[Inst[2]][Inst[3]] = Inst[4];
						VIP = VIP + 1;
						Inst = Instr[VIP];
						A = Inst[2];
						Stk[A](Unpack(Stk, A + 1, Inst[3]));
						VIP = VIP + 1;
						Inst = Instr[VIP];
						VIP = Inst[3];
					end
				elseif (Enum <= 64) then
					Stk[Inst[2]] = Inst[3] ~= 0;
				elseif (Enum > 65) then
					local FlatIdent_3501F = 0;
					local B;
					local A;
					while true do
						if (FlatIdent_3501F == 0) then
							B = nil;
							A = nil;
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							FlatIdent_3501F = 1;
						end
						if (1 == FlatIdent_3501F) then
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							FlatIdent_3501F = 2;
						end
						if (FlatIdent_3501F == 7) then
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							FlatIdent_3501F = 8;
						end
						if (5 == FlatIdent_3501F) then
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							FlatIdent_3501F = 6;
						end
						if (FlatIdent_3501F == 3) then
							Stk[A] = B[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							FlatIdent_3501F = 4;
						end
						if (2 == FlatIdent_3501F) then
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							FlatIdent_3501F = 3;
						end
						if (8 == FlatIdent_3501F) then
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							break;
						end
						if (6 == FlatIdent_3501F) then
							Inst = Instr[VIP];
							A = Inst[2];
							B = Stk[Inst[3]];
							Stk[A + 1] = B;
							FlatIdent_3501F = 7;
						end
						if (FlatIdent_3501F == 4) then
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
							VIP = VIP + 1;
							FlatIdent_3501F = 5;
						end
					end
				else
					local B;
					local A;
					A = Inst[2];
					B = Stk[Inst[3]];
					Stk[A + 1] = B;
					Stk[A] = B[Inst[4]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = Inst[3];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					A = Inst[2];
					Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = Env[Inst[3]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					A = Inst[2];
					B = Stk[Inst[3]];
					Stk[A + 1] = B;
					Stk[A] = B[Inst[4]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = Inst[3];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					A = Inst[2];
					Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
					VIP = VIP + 1;
					Inst = Instr[VIP];
					A = Inst[2];
					B = Stk[Inst[3]];
					Stk[A + 1] = B;
					Stk[A] = B[Inst[4]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = Inst[3];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					A = Inst[2];
					Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = Stk[Inst[3]];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					Stk[Inst[2]] = Inst[3];
					VIP = VIP + 1;
					Inst = Instr[VIP];
					VIP = Inst[3];
				end
				VIP = VIP + 1;
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!2E3O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O7470476574033D3O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F73686C6578776172652F4F72696F6E2F6D61696E2F736F75726365030A3O004D616B6557696E646F7703043O004E616D6503163O00456D6F726561205072656D69756D2056657273696F6E030B3O00486964655072656D69756D0100030A3O0053617665436F6E6669672O01030C3O00436F6E666967466F6C646572030D3O00456D6F7265615072656D69756D030B3O005072656D69756D4F6E6C7903103O004D616B654E6F74696669636174696F6E030A3O005468616E6B20796F752103073O00436F6E74656E7403423O005468616E6B20796F7520666F72207573696E67206F75722070726F647563742C2077652077692O6C206265207570646174696E6720616C6D6F7374206461696C792103053O00496D61676503183O00726278612O73657469643A2O2F3O31303O343738303403043O0054696D65026O00244003073O004D616B65546162030B3O0041726B616E73617320525003043O0049636F6E03173O00726278612O73657469643A2O2F2O34382O3334352O3938030E3O00536F757468204361726F6C696E61030E3O00436F6D696E6720532O6F6E3O2E030A3O00412O6453656374696F6E030B3O004D55535420454E41424C4503093O00412O6442752O746F6E03113O00427970612O7320416E746920436865617403083O0043612O6C6261636B03043O004D41494E031B3O00506C617920796F752061726520616E204964696F74204D7573696303083O004561722052617065030D3O00536572766572204675636B6572030C3O00437261736820536572766572030C3O0053702O6F6620506C61796572031A3O00456D6F72656120446576656C6F70657273204F6E6C79203A2O33030F3O005374612O6620446574656374696F6E030F3O0054687567205368616B657220412O6C030B3O004B692O6C20536572766572030B3O004578706C6F646520412O6C030E3O00436F6D696E6720732O6F6E203A7003043O00496E6974008A3O00121B3O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O0001000200202O00013O00054O00033O000500302O0003000600070030030003000800090030350003000A000B00302O0003000C000D00302O0003000E00094O00010003000200202O00023O000F4O00043O000400302O00040006001000302O00040011001200302O00040013001400302O0004001500162O001F00020004000100201C0002000100174O00043O000300302O00040006001800302O00040019001A00302O0004000E00094O00020004000200202O0003000100174O00053O000300302O00050006001B00302O00050019001A0030030005000E00092O002A00030005000200202O0004000100174O00063O000300302O00060006001C00302O00060019001A00302O0006000E00094O00040006000200202O00050002001D4O00073O000100302O00070006001E2O003D00050007000200203400060002001F2O001600083O000200300300080006002000022800095O00101A0008002100094O00060008000100202O00060002001D4O00083O000100302O0008000600222O003D00060008000200203400070002001F2O001600093O0002003003000900060023000228000A00013O00101A00090021000A4O00070009000100202O00070002001F4O00093O000200302O000900060024000228000A00023O00101A00090021000A4O00070009000100202O00070002001F4O00093O000200302O000900060025000228000A00033O00101A00090021000A4O00070009000100202O00070002001F4O00093O000200302O000900060026000228000A00043O00101A00090021000A4O00070009000100202O00070002001F4O00093O000200302O000900060027000228000A00053O00101A00090021000A4O00070009000100202O00070002001D4O00093O000100302O0009000600282O003D00070009000200203400080002001F2O0016000A3O0002003003000A0006002900060F000B0006000100012O00187O00101A000A0021000B4O0008000A000100202O00080002001F4O000A3O000200302O000A0006002A00060F000B0007000100012O00187O00101A000A0021000B4O0008000A000100202O00080002001F4O000A3O000200302O000A0006002B00060F000B0008000100012O00187O00101A000A0021000B4O0008000A000100202O00080003001F4O000A3O000200302O000A00060020000228000B00093O00101A000A0021000B4O0008000A000100202O00080003001F4O000A3O000200302O000A0006002C000228000B000A3O00101A000A0021000B4O0008000A000100202O00080003001F4O000A3O000200302O000A00060025000228000B000B3O00101A000A0021000B4O0008000A000100202O00080004001F4O000A3O000200302O000A0006002D00060F000B000C000100012O00187O002O10000A0021000B4O0008000A000100202O00083O002E4O0008000200019O006O00013O000D3O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403503O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F55736572333233393534332F7364677569736472676A68776168732F6D61696E2F74726275697274756A2E6C756100083O00124O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O000100016O00017O000E3O00028O0003013O005203043O0067616D6503093O00576F726B7370616365030E3O0046696E6446697273744368696C64030F3O004D7248612O7A696E67746F6E436172030D3O004143365F46455F536F756E647303083O00736574536F756E64026O00F03F026O00344003173O00726278612O73657469643A2O2F37322O362O3031373932030A3O004669726553657276657203063O00756E7061636B03083O00506C617941726773001D3O0012313O00013O0026243O000D0001000100040B3O000D0001001232000100033O00203C00010001000400202O00010001000500122O000300066O00010003000200202O00010001000700122O000100023O00022800015O001221000100083O0012313O00093O0026243O00010001000900040B3O00010001001232000100083O001219000200093O00122O0003000A3O00122O0004000B6O00010004000100122O000100023O00202O00010001000C00122O0003000D3O00122O0004000E6O000300046O00013O000100044O001C000100040B3O000100012O00093O00013O00013O00163O00028O00026O00F03F03013O0052030A3O004669726553657276657203063O00756E7061636B03043O004172677303083O006E6577536F756E64027O004003183O00636F6E666C696374706C617965723020776173206865726503043O006D61746803063O0072616E646F6D023O00C07D455641026O00084003043O0067616D65030D3O00496E7365727453657276696365026O001040026O001440026O001840026O001C402O0103083O00506C61794172677303093O00706C6179536F756E64032C3O001231000300014O001E000400043O002624000300020001000100040B3O00020001001231000400013O0026240004000E0001000200040B3O000E0001001232000500033O00201D00050005000400122O000700053O00122O000800066O000700086O00053O000100044O002B0001002624000400050001000100040B3O000500012O001600053O000700302900050002000700122O000600093O00122O0007000A3O00202O00070007000B00122O0008000C6O0007000200024O00060006000700102O00050008000600122O0006000E3O00202O00060006000F00102O0005000D000600102O00050010000200102O000500113O00102O00050012000100302O00050013001400122O000500066O00053O000200302O00050002001600122O000600063O00202O00060006000800102O00050008000600122O000500153O00122O000400023O00044O0005000100040B3O002B000100040B3O000200012O00093O00017O00063O0003043O006E65787403093O00776F726B7370616365030E3O0047657444657363656E64616E74732O033O0049734103053O00536F756E6403043O00506C6179000F3O0012063O00013O00122O000100023O00202O0001000100034O00010002000200044O000C0001002034000500040004001231000700054O003D0005000700020006070005000C00013O00040B3O000C00010020340005000400062O00360005000200010006043O00050001000200040B3O000500012O00093O00017O00163O00028O00027O004003043O006E65787403043O0067616D65030E3O0047657444657363656E64616E74732O033O00497341030B3O00537472696E6756616C7565030D3O00454D4F455241204F4E20544F50030B3O004E756D62657256616C756503083O00496E7456616C7565023O00A031580E44026O00F03F030B3O004F626A65637456616C756503093O00422O6F6C56616C7565030A3O004765745365727669636503113O005265706C69636174656453746F72616765030A3O004143535F456E67696E6503063O004576656E7473030A3O00526563612O7265676172030B3O00482O747053657276696365030A3O004A534F4E4465636F6465030B1A2O007B22506172656E74223A6E752O6C2C22536F75726365412O7365744964223A2D312C224D616E75616C41637469766174696F6E4F6E6C79223A66616C73652C2244617461436F7374223A36352C22526571756972657348616E646C65223A66616C73652C22412O74726962757465735265706C6963617465223A2O222C22412O747269627574657353657269616C697A65223A2O222C2247726970466F7277617264223A6E752O6C2C2261726368697661626C65223A747275652C2243616E426544726F2O706564223A66616C73652C22412O7472696275746573223A2O222C2241726368697661626C65223A747275652C22456E61626C6564223A747275652C22436C612O734E616D65223A22542O6F6C222C2254616773223A2O222C22542O6F6C546970223A2O222C22477269705269676874223A6E752O6C2C2250726F706572747953746174757353747564696F223A6E752O6C2C22546578747572654964223A2O222C2247726970506F73223A6E752O6C2C226E756D45787065637465644469726563744368696C6472656E223A302C224E616D65223A2252656E652O7469222C22636C612O734E616D65223A22542O6F6C222C22526F626C6F784C6F636B6564223A66616C73652C2247726970223A6E752O6C2C22477269705570223A6E752O6C2C224143535F4D6F64756C6F223A7B22566172696176656973223A7B22536F75726365412O7365744964223A2D312C22506172656E74223A6E752O6C2C226E756D45787065637465644469726563744368696C6472656E223A302C225A65726F696E67223A7B22412O7472696275746573223A2O222C224D696E56616C7565223A302C22506172656E74223A6E752O6C2C2250726F706572747953746174757353747564696F223A6E752O6C2C22436F6E73747261696E656456616C7565223A302C2244617461436F7374223A342C22412O74726962757465735265706C6963617465223A2O222C22412O747269627574657353657269616C697A65223A2O222C2256616C7565223A302C224D617856616C7565223A302C2261726368697661626C65223A747275652C226E756D45787065637465644469726563744368696C6472656E223A302C22536F75726365412O7365744964223A2D312C22436C612O734E616D65223A22446F75626C65436F6E73747261696E656456616C7565222C224E616D65223A225A65726F696E67222C22636C612O734E616D65223A22446F75626C65436F6E73747261696E656456616C7565222C22526F626C6F784C6F636B6564223A66616C73652C2254616773223A2O222C2241726368697661626C65223A747275652C2276616C7565223A307D2C224C61756E63686572412O6D6F223A7B22412O7472696275746573223A2O222C224D696E56616C7565223A302C22506172656E74223A6E752O6C2C2250726F706572747953746174757353747564696F223A6E752O6C2C22436F6E73747261696E656456616C7565223A6E752O6C2C2244617461436F7374223A342C22412O74726962757465735265706C6963617465223A2O222C22412O747269627574657353657269616C697A65223A2O222C2256616C7565223A6E752O6C2C224D617856616C7565223A6E752O6C2C2261726368697661626C65223A747275652C226E756D45787065637465644469726563744368696C6472656E223A302C22536F75726365412O7365744964223A2D312C22436C612O734E616D65223A22446F75626C65436F6E73747261696E656456616C7565222C224E616D65223A224C61756E63686572412O6D6F222C22636C612O734E616D65223A22446F75626C65436F6E73747261696E656456616C7565222C22526F626C6F784C6F636B6564223A66616C73652C2254616773223A2O222C2241726368697661626C65223A747275652C2276616C7565223A6E752O6C7D2C22412O74726962757465735265706C6963617465223A2O222C22412O7472696275746573223A2O222C22636C612O734E616D65223A22466F6C646572222C225265706C696361746564477569496E73657274696F6E4F72646572223A323134373438333634372C2253652O74696E6773223A7B2250726F706572747953746174757353747564696F223A6E752O6C2C22536F75726365223A2O222C22412O74726962757465735265706C6963617465223A2O222C2253637269707447756964223A227B45383645322O43382D413644382D344430382D414544412D343246322O342O38354334397D222C22536F75726365412O7365744964223A2D312C22412O7472696275746573223A2O222C22526F626C6F784C6F636B6564223A66616C73652C22486173412O736F636961746564447261667473223A66616C73652C22436F6E666964656E7469616C223A66616C73652C22412O747269627574657353657269616C697A65223A2O222C2243616368656452656D6F7465536F75726365223A2O222C2243616368656452656D6F7465536F757263654C6F61645374617465223A302C2241726368697661626C65223A747275652C2254616773223A2O222C22506172656E74223A6E752O6C2C22436C612O734E616D65223A224D6F64756C65536372697074222C224F726967696E616C53637269707447756964223A227B34313046434530312D342O41432D343335382D413343372D3844303945444535343533367D222C22497344692O666572656E7446726F6D46696C6553797374656D223A66616C73652C224C696E6B6564536F75726365223A2O222C224E616D65223A2253652O74696E6773222C22636C612O734E616D65223A224D6F64756C65536372697074222C2244617461436F7374223A342C226E756D45787065637465644469726563744368696C6472656E223A302C2261726368697661626C65223A747275657D2C22474C4368616D6265726564223A7B22536F75726365412O7365744964223A2D312C22506172656E74223A6E752O6C2C226E756D45787065637465644469726563744368696C6472656E223A302C22412O747269627574657353657269616C697A65223A2O222C2250726F706572747953746174757353747564696F223A6E752O6C2C2254616773223A2O222C2244617461436F7374223A342C22412O74726962757465735265706C6963617465223A2O222C2256616C7565223A66616C73652C22436C612O734E616D65223A22422O6F6C56616C7565222C224E616D65223A22474C4368616D6265726564222C22636C612O734E616D65223A22422O6F6C56616C7565222C22526F626C6F784C6F636B6564223A66616C73652C22412O7472696275746573223A2O222C2261726368697661626C65223A747275652C2241726368697661626C65223A747275657D2C224254797065223A7B22536F75726365412O7365744964223A2D312C22506172656E74223A6E752O6C2C226E756D45787065637465644469726563744368696C6472656E223A302C22412O747269627574657353657269616C697A65223A2O222C2250726F706572747953746174757353747564696F223A6E752O6C2C2254616773223A2O222C2244617461436F7374223A352C22412O74726962757465735265706C6963617465223A2O222C2256616C7565223A22392O6D222C22436C612O734E616D65223A22537472696E6756616C7565222C224E616D65223A224254797065222C22636C612O734E616D65223A22537472696E6756616C7565222C22526F626C6F784C6F636B6564223A66616C73652C22412O7472696275746573223A2O222C2261726368697661626C65223A747275652C2241726368697661626C65223A747275657D2C2261726368697661626C65223A747275652C22456D70652O7261646F223A7B22536F75726365412O7365744964223A2D312C22506172656E74223A6E752O6C2C226E756D45787065637465644469726563744368696C6472656E223A302C22412O747269627574657353657269616C697A65223A2O222C2250726F706572747953746174757353747564696F223A6E752O6C2C2254616773223A2O222C2244617461436F7374223A342C22412O74726962757465735265706C6963617465223A2O222C2256616C7565223A66616C73652C22436C612O734E616D65223A22422O6F6C56616C7565222C224E616D65223A22456D70652O7261646F222C22636C612O734E616D65223A22422O6F6C56616C7565222C22526F626C6F784C6F636B6564223A66616C73652C22412O7472696275746573223A2O222C2261726368697661626C65223A747275652C2241726368697661626C65223A747275657D2C2244617461436F7374223A35332C224368616D6265726564223A7B22536F75726365412O7365744964223A2D312C22506172656E74223A6E752O6C2C226E756D45787065637465644469726563744368696C6472656E223A302C22412O747269627574657353657269616C697A65223A2O222C2250726F706572747953746174757353747564696F223A6E752O6C2C2254616773223A2O222C2244617461436F7374223A342C22412O74726962757465735265706C6963617465223A2O222C2256616C7565223A747275652C22436C612O734E616D65223A22422O6F6C56616C7565222C224E616D65223A224368616D6265726564222C22636C612O734E616D65223A22422O6F6C56616C7565222C22526F626C6F784C6F636B6564223A66616C73652C22412O7472696275746573223A2O222C2261726368697661626C65223A747275652C2241726368697661626C65223A747275657D2C2253656E73223A7B22412O7472696275746573223A2O222C224D696E56616C7565223A352C22506172656E74223A6E752O6C2C2250726F706572747953746174757353747564696F223A6E752O6C2C22436F6E73747261696E656456616C7565223A35302C2244617461436F7374223A342C22412O74726962757465735265706C6963617465223A2O222C22412O747269627574657353657269616C697A65223A2O222C2256616C7565223A35302C224D617856616C7565223A312O302C2261726368697661626C65223A747275652C226E756D45787065637465644469726563744368696C6472656E223A302C22536F75726365412O7365744964223A2D312C22436C612O734E616D65223A22446F75626C65436F6E73747261696E656456616C7565222C224E616D65223A2253656E73222C22636C612O734E616D65223A22446F75626C65436F6E73747261696E656456616C7565222C22526F626C6F784C6F636B6564223A66616C73652C2254616773223A2O222C2241726368697661626C65223A747275652C2276616C7565223A35307D2C2254616773223A2O222C22412O6D6F223A7B22536F75726365412O7365744964223A2D312C22506172656E74223A6E752O6C2C226E756D45787065637465644469726563744368696C6472656E223A302C22412O747269627574657353657269616C697A65223A2O222C2250726F706572747953746174757353747564696F223A6E752O6C2C2254616773223A2O222C2244617461436F7374223A342C22412O74726962757465735265706C6963617465223A2O222C2256616C7565223A382C22436C612O734E616D65223A224E756D62657256616C7565222C224E616D65223A22412O6D6F222C22636C612O734E616D65223A224E756D62657256616C7565222C22526F626C6F784C6F636B6564223A66616C73652C22412O7472696275746573223A2O222C2261726368697661626C65223A747275652C2241726368697661626C65223A747275657D2C22416E696D6174696F6E73223A7B2250726F706572747953746174757353747564696F223A6E752O6C2C22536F75726365223A2O222C22412O74726962757465735265706C6963617465223A2O222C2253637269707447756964223A227B2O363041423731452D353044352D343932352D393531362D42432O3537303132384345347D222C22536F75726365412O7365744964223A2D312C22412O7472696275746573223A2O222C22526F626C6F784C6F636B6564223A66616C73652C22486173412O736F636961746564447261667473223A66616C73652C22436F6E666964656E7469616C223A66616C73652C22412O747269627574657353657269616C697A65223A2O222C2243616368656452656D6F7465536F75726365223A2O222C2243616368656452656D6F7465536F757263654C6F61645374617465223A302C2241726368697661626C65223A747275652C2254616773223A2O222C22506172656E74223A6E752O6C2C22436C612O734E616D65223A224D6F64756C65536372697074222C224F726967696E616C53637269707447756964223A227B31413130394638302D303645322D344633412D393536372D31374131352O3832413632457D222C22497344692O666572656E7446726F6D46696C6553797374656D223A66616C73652C224C696E6B6564536F75726365223A2O222C224E616D65223A22416E696D6174696F6E73222C22636C612O734E616D65223A224D6F64756C65536372697074222C2244617461436F7374223A342C226E756D45787065637465644469726563744368696C6472656E223A302C2261726368697661626C65223A747275657D2C2250726F706572747953746174757353747564696F223A6E752O6C2C2253746F726564412O6D6F223A7B22412O7472696275746573223A2O222C224D696E56616C7565223A302C22506172656E74223A6E752O6C2C2250726F706572747953746174757353747564696F223A6E752O6C2C22436F6E73747261696E656456616C7565223A36312C2244617461436F7374223A342C22412O74726962757465735265706C6963617465223A2O222C22412O747269627574657353657269616C697A65223A2O222C2256616C7565223A36312C224D617856616C7565223A3137302C2261726368697661626C65223A747275652C226E756D45787065637465644469726563744368696C6472656E223A302C22536F75726365412O7365744964223A2D312C22436C612O734E616D65223A22446F75626C65436F6E73747261696E656456616C7565222C224E616D65223A2253746F726564412O6D6F222C22636C612O734E616D65223A22446F75626C65436F6E73747261696E656456616C7565222C22526F626C6F784C6F636B6564223A66616C73652C2254616773223A2O222C2241726368697661626C65223A747275652C2276616C7565223A36317D2C22412O747269627574657353657269616C697A65223A2O222C224E616D65223A22566172696176656973222C22526F626C6F784C6F636B6564223A66616C73652C22436C612O734E616D65223A22466F6C646572222C2253752O7072652O736F72223A7B22536F75726365412O7365744964223A2D312C22506172656E74223A6E752O6C2C226E756D45787065637465644469726563744368696C6472656E223A302C22412O747269627574657353657269616C697A65223A2O222C2250726F706572747953746174757353747564696F223A6E752O6C2C2254616773223A2O222C2244617461436F7374223A342C22412O74726962757465735265706C6963617465223A2O222C2256616C7565223A66616C73652C22436C612O734E616D65223A22422O6F6C56616C7565222C224E616D65223A2253752O7072652O736F72222C22636C612O734E616D65223A22422O6F6C56616C7565222C22526F626C6F784C6F636B6564223A66616C73652C22412O7472696275746573223A2O222C2261726368697661626C65223A747275652C2241726368697661626C65223A747275657D2C2241726368697661626C65223A747275657D2C22536F75726365412O7365744964223A2D312C22506172656E74223A6E752O6C2C22412O74726962757465735265706C6963617465223A2O222C2254616773223A2O222C224143535F5365747570223A7B2250726F706572747953746174757353747564696F223A6E752O6C2C22536F75726365223A2O222C22412O74726962757465735265706C6963617465223A2O222C2253637269707447756964223A227B3242372O454430432D333938432D343643362D412O44392D3243314536343537363334447D222C22536F75726365412O7365744964223A2D312C22412O7472696275746573223A2O222C22526F626C6F784C6F636B6564223A66616C73652C22486173412O736F636961746564447261667473223A66616C73652C22436F6E666964656E7469616C223A66616C73652C22412O747269627574657353657269616C697A65223A2O222C2243616368656452656D6F7465536F75726365223A2O222C2243616368656452656D6F7465536F757263654C6F61645374617465223A302C2241726368697661626C65223A747275652C2254616773223A2O222C22506172656E74223A6E752O6C2C22436C612O734E616D65223A224D6F64756C65536372697074222C224F726967696E616C53637269707447756964223A227B37343844373530372D354546312D343046382D412O38302D3043304639434544324136437D222C22497344692O666572656E7446726F6D46696C6553797374656D223A66616C73652C224C696E6B6564536F75726365223A2O222C224E616D65223A224143535F5365747570222C22636C612O734E616D65223A224D6F64756C65536372697074222C2244617461436F7374223A342C226E756D45787065637465644469726563744368696C6472656E223A302C2261726368697661626C65223A747275657D2C22412O7472696275746573223A2O222C2261726368697661626C65223A747275652C2250726F706572747953746174757353747564696F223A6E752O6C2C226E756D45787065637465644469726563744368696C6472656E223A302C22412O747269627574657353657269616C697A65223A2O222C2244617461436F7374223A36312C224E616D65223A224143535F4D6F64756C6F222C225265706C696361746564477569496E73657274696F6E4F72646572223A323134373438333634372C22636C612O734E616D65223A22466F6C646572222C22526F626C6F784C6F636B6564223A66616C73652C22436C612O734E616D65223A22466F6C646572222C2241726368697661626C65223A747275652O7D00683O0012313O00014O001E000100033O0026243O003D0001000200040B3O003D0001001232000400033O001232000500043O0020340005000500052O001300050002000600040B3O003A0001001231000900013O002624000900240001000100040B3O00240001002034000A00080006001231000C00074O003D000A000C0002000607000A001500013O00040B3O001500012O0018000A00034O0018000B00083O001231000C00084O001F000A000C0001002034000A00080006001231000C00094O003D000A000C000200060E000A001F0001000100040B3O001F0001002034000A00080006001231000C000A4O003D000A000C0002000607000A002300013O00040B3O002300012O0018000A00034O0018000B00083O001231000C000B4O001F000A000C00010012310009000C3O0026240009000A0001000C00040B3O000A0001002034000A00080006001231000C000D4O003D000A000C0002000607000A002F00013O00040B3O002F00012O0018000A00034O0018000B00083O001232000C00044O001F000A000C0001002034000A00080006001231000C000E4O003D000A000C0002000607000A003A00013O00040B3O003A00012O0018000A00034O0018000B00084O0040000C00014O001F000A000C000100040B3O003A000100040B3O000A0001000604000400090001000200040B3O0009000100040B3O006700010026243O004C0001000C00040B3O004C0001001231000400013O002624000400440001000C00040B3O004400010012313O00023O00040B3O004C0001002624000400400001000100040B3O004000012O001E000300033O00060F00033O000100022O00183O00024O00183O00013O0012310004000C3O00040B3O004000010026243O00020001000100040B3O00020001001231000400013O002624000400530001000C00040B3O005300010012313O000C3O00040B3O00020001000E2B0001004F0001000400040B3O004F0001001232000500043O00204100050005000F00122O000700106O00050007000200202O00050005001100202O00050005001200202O00010005001300122O000500043O00202O00050005000F00122O000700146O00050007000200202O00050005001500122O000700166O0005000700024O000200053O00122O0004000C3O00044O004F000100040B3O000200012O00093O00013O00013O00053O00028O0003043O006E657874030A3O004143535F4D6F64756C6F03093O00566172696176656973030A3O0046697265536572766572021D3O001231000200014O001E000300033O002624000200020001000100040B3O00020001001231000300013O002624000300050001000100040B3O00050001001232000400024O003900055O00202O00050005000300202O0005000500044O000600063O00044O001100012O003800095O0020020009000900030020020009000900042O0001000900073O0006040004000D0001000200040B3O000D00012O0038000400013O0020150004000400054O000600016O00078O00040007000100044O001C000100040B3O0005000100040B3O001C000100040B3O000200012O00093O00017O00023O0003053O007072696E74030E3O0062752O746F6E207072652O73656400043O0012323O00013O001231000100024O00363O000200012O00093O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O7470476574034D3O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F55736572333233393534332F646775686B6572676235752F6D61696E2F3733796A74696A7472792E6C756100083O00124O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O000100016O00017O00113O00028O00026O00F03F03103O004D616B654E6F74696669636174696F6E03043O004E616D65030F3O005374612O6620446574656374696F6E03073O00436F6E74656E7403283O00576520686176652044657465637465642041726B616E736173207374612O6620696E2D67616D652103053O00496D61676503173O00726278612O73657469643A2O2F2O34382O3334352O393803043O0054696D65026O001440030A3O006C6F6164737472696E6703043O0067616D6503073O00482O7470476574034F3O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F55736572333233393534332F356279753962796B75723674756E2F6D61696E2F7364666A6B736467662E6C756103043O0077616974026O33D33F00213O0012313O00014O001E000100013O0026243O00020001000100040B3O00020001001231000100013O002624000100100001000200040B3O001000012O003800025O00203E0002000200034O00043O000400302O00040004000500302O00040006000700302O00040008000900302O0004000A000B4O00020004000100044O00200001002624000100050001000100040B3O000500010012320002000C3O00122F0003000D3O00202O00030003000E00122O0005000F6O000300056O00023O00024O00020001000100122O000200103O00122O000300116O00020002000100122O000100023O00044O0005000100040B3O0020000100040B3O000200012O00093O00017O00093O0003103O004D616B654E6F74696669636174696F6E03043O004E616D6503043O00532O4F4E03073O00436F6E74656E74030C3O00436F6D696E6720532O6F6E2103053O00496D61676503183O00726278612O73657469643A2O2F313831362O34313432363203043O0054696D65026O00084000094O00257O00206O00014O00023O000400302O00020002000300302O00020004000500302O00020006000700302O0002000800096O000200016O00017O00093O0003103O004D616B654E6F74696669636174696F6E03043O004E616D6503043O00532O4F4E03073O00436F6E74656E74030C3O00436F6D696E6720532O6F6E2103053O00496D61676503183O00726278612O73657469643A2O2F313831362O34313432363203043O0054696D65026O00084000094O00257O00206O00014O00023O000400302O00020002000300302O00020004000500302O00020006000700302O0002000800096O000200016O00019O003O00014O00093O00019O003O00014O00093O00019O003O00014O00093O00017O00093O0003103O004D616B654E6F74696669636174696F6E03043O004E616D65030C3O00436F6D696E6720532O6F6E2103073O00436F6E74656E74030B3O00534O4F2O4E203A2O3303053O00496D61676503173O00726278612O73657469643A2O2F2O34382O3334352O393803043O0054696D65026O00144000094O00257O00206O00014O00023O000400302O00020002000300302O00020004000500302O00020006000700302O0002000800096O000200016O00017O00", GetFEnv(), ...);