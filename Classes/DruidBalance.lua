-- DruidBalance.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'DRUID' then
    local spec = Hekili:NewSpecialization( 102, true )

    spec:RegisterResource( Enum.PowerType.LunarPower, {
        fury_of_elune = {            
            aura = "fury_of_elune_ap",

            last = function ()
                local app = state.buff.fury_of_elune_ap.applied
                local t = state.query_time

                return app + floor( ( t - app ) / 0.5 ) * 0.5
            end,

            interval = 0.5,
            value = 2.5
        }
    } )


    spec:RegisterResource( Enum.PowerType.Mana )
    spec:RegisterResource( Enum.PowerType.Energy )
    spec:RegisterResource( Enum.PowerType.ComboPoints )
    spec:RegisterResource( Enum.PowerType.Rage )
    
    -- Talents
    spec:RegisterTalents( {
        natures_balance = 22385, -- 202430
        warrior_of_elune = 22386, -- 202425
        force_of_nature = 22387, -- 205636

        tiger_dash = 19283, -- 252216
        renewal = 18570, -- 108238
        wild_charge = 18571, -- 102401

        feral_affinity = 22155, -- 202157
        guardian_affinity = 22157, -- 197491
        restoration_affinity = 22159, -- 197492

        mighty_bash = 21778, -- 5211
        mass_entanglement = 18576, -- 102359
        typhoon = 18577, -- 132469

        soul_of_the_forest = 18580, -- 114107
        starlord = 21706, -- 202345
        incarnation = 21702, -- 102560

        stellar_drift = 22389, -- 202354
        twin_moons = 21712, -- 279620
        stellar_flare = 22165, -- 202347

        shooting_stars = 21648, -- 202342
        fury_of_elune = 21193, -- 202770
        new_moon = 21655, -- 274281
    } )

    
    -- PvP Talents
    spec:RegisterPvpTalents( { 
        adaptation = 3543, -- 214027
        relentless = 3542, -- 196029
        gladiators_medallion = 3541, -- 208683

        celestial_downpour = 183, -- 200726
        celestial_guardian = 180, -- 233754
        crescent_burn = 182, -- 200567
        cyclone = 857, -- 209753
        deep_roots = 834, -- 233755
        dying_stars = 822, -- 232546
        faerie_swarm = 836, -- 209749
        ironfeather_armor = 1216, -- 233752
        moon_and_stars = 184, -- 233750
        moonkin_aura = 185, -- 209740
        prickling_thorns = 3058, -- 200549
        protector_of_the_grove = 3728, -- 209730
        thorns = 3731, -- 236696
    } )

    
    spec:RegisterPower( "lively_spirit", 279642, {
        id = 279648,
        duration = 20,
        max_stack = 1,
    } )


    -- Auras
    spec:RegisterAuras( {
        aquatic_form = {
            id = 276012,
        },
        astral_influence = {
            id = 197524,
        },
        barkskin = {
            id = 22812,
            duration = 12,
            max_stack = 1,
        },
        bear_form = {
            id = 5487,
            duration = 3600,
            max_stack = 1,
        },
        blessing_of_cenarius = {
            id = 238026,
            duration = 60,
            max_stack = 1,
        },
        blessing_of_the_ancients = {
            id = 206498,
            duration = 3600,
            max_stack = 1,
        },
        cat_form = {
            id = 768,
            duration = 3600,
            max_stack = 1,
        },
        celestial_alignment = {
            id = 194223,
            duration = 20,
            max_stack = 1,
        },
        dash = {
            id = 1850,
            duration = 10,
            max_stack = 1,
        },
        eclipse = {
            id = 279619,
        },
        empowerments = {
            id = 279708,
        },
        entangling_roots = {
            id = 339,
            duration = 30,
            type = "Magic",
            max_stack = 1,
        },
        feline_swiftness = {
            id = 131768,
        },
        flask_of_the_seventh_demon = {
            id = 188033,
            duration = 3600.006,
            max_stack = 1,
        },
        flight_form = {
            id = 276029,
        },
        force_of_nature = {
            id = 205644,
            duration = 15,
            max_stack = 1,
        },
        frenzied_regeneration = {
            id = 22842,
            duration = 3,
            max_stack = 1,
        },
        fury_of_elune_ap = {
            id = 202770,
            duration = 8,
            max_stack = 1,
    
            generate = function ()
                local foe = buff.fury_of_elune_ap
                local applied = action.fury_of_elune.lastCast
    
                if applied and now - applied < 8 then
                    foe.count = 1
                    foe.expires = applied + 8
                    foe.applied = applied
                    foe.caster = "player"
                    return
                end
    
                foe.count = 0
                foe.expires = 0
                foe.applied = 0
                foe.caster = "nobody"
            end,
        },
        growl = {
            id = 6795,
            duration = 3,
            max_stack = 1,
        },
        incarnation = {
            id = 102560,
            duration = 30,
            max_stack = 1,
            copy = "incarnation_chosen_of_elune"
        },
        ironfur = {
            id = 192081,
            duration = 7,
            max_stack = 1,
        },
        legionfall_commander = {
            id = 233641,
            duration = 3600,
            max_stack = 1,
        },
        lunar_empowerment = {
            id = 164547,
            duration = 45,
            type = "Magic",
            max_stack = 3,
        },
        mana_divining_stone = {
            id = 227723,
            duration = 3600,
            max_stack = 1,
        },
        mass_entanglement = {
            id = 102359,
            duration = 30,
            type = "Magic",
            max_stack = 1,
        },
        mighty_bash = {
            id = 5211,
            duration = 5,
            max_stack = 1,
        },
        moonfire = {
            id = 164812,
            duration = 22,
            tick_time = function () return 2 * haste end,
            type = "Magic",
            max_stack = 1,
        },
        moonkin_form = {
            id = 24858,
            duration = 3600,
            max_stack = 1,
        },
        prowl = {
            id = 5215,
            duration = 3600,
            max_stack = 1,
        },
        regrowth = {
            id = 8936,
            duration = 12,
            type = "Magic",
            max_stack = 1,
        },
        shadowmeld = {
            id = 58984,
            duration = 3600,
            max_stack = 1,
        },
        sign_of_the_critter = {
            id = 186406,
            duration = 3600,
            max_stack = 1,
        },
        solar_beam = {
            id = 81261,
            duration = 3600,
            max_stack = 1,
        },
        solar_empowerment = {
            id = 164545,
            duration = 45,
            type = "Magic",
            max_stack = 3,
        },
        stag_form = {
            id = 210053,
            duration = 3600,
            max_stack = 1,
            generate = function ()
                local form = GetShapeshiftForm()
                local stag = form and form > 0 and select( 4, GetShapeshiftFormInfo( form ) )
                
                local sf = buff.stag_form

                if stag == 210053 then
                    sf.count = 1
                    sf.applied = now
                    sf.expires = now + 3600
                    sf.caster = "player"
                    return
                end

                sf.count = 0
                sf.applied = 0
                sf.expires = 0
                sf.caster = "nobody"
            end,
        },
        starfall = {
            id = 191034,
            duration = function () return pvptalent.celestial_downpour.enabled and 16 or 8 end,
            max_stack = 1,

            generate = function ()
                local sf = buff.starfall

                if now - action.starfall.lastCast < 8 then
                    sf.count = 1
                    sf.applied = action.starfall.lastCast
                    sf.expires = sf.applied + 8
                    sf.caster = "player"
                    return
                end

                sf.count = 0
                sf.applied = 0
                sf.expires = 0
                sf.caster = "nobody"
            end
        },
        starlord = {
            id = 279709,
            duration = 20,
            max_stack = 3,
        },
        stellar_drift = {
            id = 202461,
            duration = 3600,
            max_stack = 1,
        },
        stellar_flare = {
            id = 202347,
            duration = 24,
            tick_time = function () return 2 * haste end,
            type = "Magic",
            max_stack = 1,
        },
        sunfire = {
            id = 164815,
            duration = 18,
            tick_time = function () return 2 * haste end,
            type = "Magic",
            max_stack = 1,
        },
        thick_hide = {
            id = 16931,
        },
        thorny_entanglement = {
            id = 241750,
            duration = 15,
            max_stack = 1,
        },
        thrash_bear = {
            id = 192090,
            duration = 15,
            max_stack = 3,
        },
        thrash_cat ={
            id = 106830, 
            duration = function()
                local x = 15 -- Base duration
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
            tick_time = function()
                local x = 3 -- Base tick time
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
        },
        --[[ thrash = {
            id = function ()
                if buff.cat_form.up then return 106830 end
                return 192090
            end,
            duration = function()
                local x = 15 -- Base duration
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
            tick_time = function()
                local x = 3 -- Base tick time
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
        }, ]]
        tiger_dash = {
            id = 252216,
            duration = 5,
            max_stack = 1,
        },
        travel_form = {
            id = 783,
            duration = 3600,
            max_stack = 1,
        },
        treant_form = {
            id = 114282,
            duration = 3600,
            max_stack = 1,
        },
        typhoon = {
            id = 61391,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },
        warrior_of_elune = {
            id = 202425,
            duration = 3600,
            type = "Magic",
            max_stack = 3,
        },
        wild_charge = {
            id = 102401,
        },
        yseras_gift = {
            id = 145108,
        },
        -- Alias for Celestial Alignment vs. Incarnation
        ca_inc = {
            alias = { "celestial_alignment", "incarnation" },
            aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
            aliasType = "buff",
            duration = function () return talent.incarnation.enabled and 30 or 20 end,
        },


        -- PvP Talents
        celestial_guardian = {
            id = 234081,
            duration = 3600,
            max_stack = 1,
        },

        cyclone = {
            id = 209753,
            duration = 6,
            max_stack = 1,
        },

        faerie_swarm = {
            id = 209749,
            duration = 5,
            type = "Magic",
            max_stack = 1,
        },

        moon_and_stars = {
            id = 234084,
            duration = 10,
            max_stack = 1,
        },

        moonkin_aura = {
            id = 209746,
            duration = 18,
            type = "Magic",
            max_stack = 3,
        },

        thorns = {
            id = 236696,
            duration = 12,
            type = "Magic",
            max_stack = 1,
        },


        -- Azerite Powers
        dawning_sun = {
            id = 276153,
            duration = 8,
            max_stack = 1,
        },

        sunblaze = {
            id = 274399,
            duration = 20,
            max_stack = 1
        },
    } )


    spec:RegisterStateFunction( "break_stealth", function ()
        removeBuff( "shadowmeld" )
        if buff.prowl.up then
            setCooldown( "prowl", 6 )
            removeBuff( "prowl" )
        end
    end )


    -- Function to remove any form currently active.
    spec:RegisterStateFunction( "unshift", function()
        removeBuff( "cat_form" )
        removeBuff( "bear_form" )
        removeBuff( "travel_form" )
        removeBuff( "moonkin_form" )
        removeBuff( "travel_form" )
        removeBuff( "aquatic_form" )
        removeBuff( "stag_form" )
        removeBuff( "celestial_guardian" )
    end )
    

    -- Function to apply form that is passed into it via string.
    spec:RegisterStateFunction( "shift", function( form )
        removeBuff( "cat_form" )
        removeBuff( "bear_form" )
        removeBuff( "travel_form" )
        removeBuff( "moonkin_form" )
        removeBuff( "travel_form" )
        removeBuff( "aquatic_form" )
        removeBuff( "stag_form" )
        applyBuff( form )
        
        if form == "bear_form" and pvptalent.celestial_guardian.enabled then
            applyBuff( "celestial_guardian" )
        end
    end )


    spec:RegisterHook( "runHandler", function( ability )
        local a = class.abilities[ ability ]
    
        if not a or a.startsCombat then
            break_stealth()
        end 
    end )


    spec:RegisterStateExpr( "active_moon", function ()
        return "new_moon"
    end )

    local function IsActiveSpell( id )
        local slot = FindSpellBookSlotBySpellID( id )
        if not slot then return false end

        local _, _, spellID = GetSpellBookItemName( slot, "spell" )
        return id == spellID 
    end

    state.IsActiveSpell = IsActiveSpell
    
    spec:RegisterHook( "reset_precast", function ()
        if IsActiveSpell( class.abilities.new_moon.id ) then active_moon = "new_moon"
        elseif IsActiveSpell( class.abilities.half_moon.id ) then active_moon = "half_moon"
        elseif IsActiveSpell( class.abilities.full_moon.id ) then active_moon = "full_moon"
        else active_moon = nil end

        -- UGLY
        if talent.incarnation.enabled then
            rawset( cooldown, "ca_inc", cooldown.incarnation )
        else
            rawset( cooldown, "ca_inc", cooldown.celestial_alignment )
        end
    end )


    spec:RegisterHook( "spend", function( amt, resource )
        if level < 116 and equipped.impeccable_fel_essence and resource == "astral_power" and cooldown.celestial_alignment.remains > 0 then
            setCooldown( "celestial_alignment", max( 0, cooldown.celestial_alignment.remains - ( amt / 12 ) ) )
        end 
    end )


    -- Legion Sets (for now).
    spec:RegisterGear( 'tier21', 152127, 152129, 152125, 152124, 152126, 152128 )
        spec:RegisterAura( 'solar_solstice', {
            id = 252767,
            duration = 6,
            max_stack = 1,
         } ) 

    spec:RegisterGear( 'tier20', 147136, 147138, 147134, 147133, 147135, 147137 )
    spec:RegisterGear( 'tier19', 138330, 138336, 138366, 138324, 138327, 138333 )
    spec:RegisterGear( 'class', 139726, 139728, 139723, 139730, 139725, 139729, 139727, 139724 )

    spec:RegisterGear( "impeccable_fel_essence", 137039 )    
    spec:RegisterGear( "oneths_intuition", 137092 )
        spec:RegisterAuras( {
            oneths_intuition = {
                id = 209406,
                duration = 3600,
                max_stacks = 1,
            },    
            oneths_overconfidence = {
                id = 209407,
                duration = 3600,
                max_stacks = 1,
            },
        } )

    spec:RegisterGear( "radiant_moonlight", 151800 )
    spec:RegisterGear( "the_emerald_dreamcatcher", 137062 )
        spec:RegisterAura( "the_emerald_dreamcatcher", {
            id = 224706,
            duration = 5,
            max_stack = 2,
        } )



    -- Abilities
    spec:RegisterAbilities( {
        barkskin = {
            id = 22812,
            cast = 0,
            cooldown = 60,
            gcd = "off",
            
            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 136097,
            
            handler = function ()
                applyBuff( "barkskin" )
            end,
        },
        

        bear_form = {
            id = 5487,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132276,

            noform = "bear_form",
            
            handler = function ()
                shift( "bear_form" )
            end,
        },
        

        cat_form = {
            id = 768,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132115,

            noform = "cat_form",
            
            handler = function ()
                shift( "cat_form" )
            end,
        },
        

        celestial_alignment = {
            id = 194223,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 136060,

            notalent = "incarnation",
            
            handler = function ()
                applyBuff( "celestial_alignment" )
                if pvptalent.moon_and_stars.enabled then applyBuff( "moon_and_stars" ) end
            end,

            copy = "ca_inc"
        },
        

        cyclone = {
            id = 209753,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",

            pvptalent = "cyclone",
            
            spend = 0.15,
            spendType = "mana",
            
            startsCombat = true,
            texture = 136022,
            
            handler = function ()
                applyDebuff( "target", "cyclone" )
            end,
        },
        

        dash = {
            id = 1850,
            cast = 0,
            cooldown = 120,
            gcd = "off",
            
            startsCombat = false,
            texture = 132120,

            notalent = "tiger_dash",
            
            handler = function ()
                if not buff.cat_form.up then
                    shift( "cat_form" )
                end
                applyBuff( "dash" )
            end,
        },
        

        --[[ dreamwalk = {
            id = 193753,
            cast = 10,
            cooldown = 60,
            gcd = "spell",
            
            spend = 4,
            spendType = "mana",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 135763,
            
            handler = function ()
            end,
        }, ]]
        

        entangling_roots = {
            id = 339,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.18,
            spendType = "mana",
            
            startsCombat = false,
            texture = 136100,
            
            handler = function ()
                applyDebuff( "target", "entangling_roots" )
            end,
        },
        

        faerie_swarm = {
            id = 209749,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            pvptalent = "faerie_swarm",

            startsCombat = true,
            texture = 538516,
            
            handler = function ()
                applyDebuff( "target", "faerie_swarm" )
            end,
        },
        

        ferocious_bite = {
            id = 22568,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 50,
            spendType = "energy",
            
            startsCombat = true,
            texture = 132127,

            form = "cat_form",
            talent = "feral_affinity",
            
            usable = function () return combo_points.current > 0 end,
            handler = function ()
                --[[ if target.health.pct < 25 and debuff.rip.up then
                    applyDebuff( "target", "rip", min( debuff.rip.duration * 1.3, debuff.rip.remains + debuff.rip.duration ) )
                end ]]
                spend( combo_points.current, "combo_points" )
            end,
        },
        

        --[[ flap = {
            id = 164862,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132925,
            
            handler = function ()
            end,
        }, ]]
        

        force_of_nature = {
            id = 205636,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            spend = -20,
            spendType = "astral_power",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 132129,

            talent = "force_of_nature",
            
            handler = function ()
                summonPet( "treants", 10 )
            end,
        },
        

        frenzied_regeneration = {
            id = 22842,
            cast = 0,
            charges = 1,
            cooldown = 36,
            recharge = 36,
            gcd = "spell",
            
            spend = 10,
            spendType = "rage",
            
            startsCombat = false,
            texture = 132091,

            form = "bear_form",
            talent = "guardian_affinity",
            
            handler = function ()
                applyBuff( "frenzied_regeneration" )
                gain( 0.08 * health.max, "health" )
            end,
        },
        

        full_moon = {
            id = 274283,
            known = 274281,
            cast = 3,
            charges = 3,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",
            
            spend = -40,
            spendType = "astral_power",

            texture = 1392542,
            startsCombat = true,

            talent = "new_moon",
            bind = "half_moon",
            
            usable = function () return active_moon == "full_moon" end,
            handler = function ()
                spendCharges( "new_moon", 1 )
                spendCharges( "half_moon", 1 )

                -- Radiant Moonlight, NYI.
                active_moon = "new_moon"
            end,
        },
        

        fury_of_elune = {
            id = 202770,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            -- toggle = "cooldowns",

            startsCombat = true,
            texture = 132123,
            
            handler = function ()
                if not buff.moonkin_form.up then unshift() end
                applyDebuff( "target", "fury_of_elune_ap" )
            end,
        },
        

        growl = {
            id = 6795,
            cast = 0,
            cooldown = 8,
            gcd = "off",
            
            startsCombat = true,
            texture = 132270,

            form = "bear_form",
            
            handler = function ()
                applyDebuff( "target", "growl" )
            end,
        },
        

        half_moon = {
            id = 274282, 
            known = 274281,
            cast = 2,
            charges = 3,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",

            spend = -20,
            spendType = "astral_power",
            
            texture = 1392543,
            startsCombat = true,

            talent = "new_moon",
            bind = "new_moon",
            
            usable = function () return active_moon == 'half_moon' end,
            handler = function ()
                spendCharges( "new_moon", 1 )
                spendCharges( "full_moon", 1 )

                active_moon = "full_moon"
            end,
        },
        

        hibernate = {
            id = 2637,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.15,
            spendType = "mana",
            
            startsCombat = false,
            texture = 136090,
            
            handler = function ()
                applyDebuff( "target", "hibernate" )
            end,
        },
        

        incarnation = {
            id = 102560,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = false,
            texture = 571586,
            
            handler = function ()
                shift( "moonkin_form" )
                applyBuff( "incarnation" )

                if pvptalent.moon_and_stars.enabled then applyBuff( "moon_and_stars" ) end
            end,

            copy = "incarnation_chosen_of_elune"
        },
        

        innervate = {
            id = 29166,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            -- toggle = "cooldowns",

            startsCombat = false,
            texture = 136048,
            
            usable = false,
            handler = function ()
                active_dot.innervate = 1
            end,
        },
        

        ironfur = {
            id = 192081,
            cast = 0,
            cooldown = 0.5,
            gcd = "spell",
            
            spend = 45,
            spendType = "rage",
            
            startsCombat = true,
            texture = 1378702,
            
            handler = function ()
                applyBuff( "ironfur" )
            end,
        },
        

        lunar_strike = {
            id = 194153,
            cast = function () 
                if buff.warrior_of_elune.up then return 0 end
                return haste * ( buff.lunar_empowerment.up and 0.85 or 1 ) * 2.25 
            end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( buff.warrior_of_elune.up and 1.4 or 1 ) * -12 end,
            spendType = "astral_power",
            
            startsCombat = true,
            texture = 135753,            
            
            handler = function ()
                if not buff.moonkin_form.up then unshift() end
                removeStack( "lunar_empowerment" )
                removeStack( "warrior_of_elune" )

                if azerite.dawning_sun.enabled then applyBuff( "dawning_sun" ) end
            end,
        },
        

        mangle = {
            id = 33917,
            cast = 0,
            cooldown = 6,
            gcd = "spell",
            
            spend = -8,
            spendType = "rage",

            startsCombat = true,
            texture = 132135,

            talent = "guardian_affinity",
            form = "bear_form",
            
            handler = function ()
            end,
        },
        

        mass_entanglement = {
            id = 102359,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = false,
            texture = 538515,

            talent = "mass_entanglement",
            
            handler = function ()
                applyDebuff( "target", "mass_entanglement" )
                active_dot.mass_entanglement = max( active_dot.mass_entanglement, active_enemies )
            end,
        },
        

        mighty_bash = {
            id = 5211,
            cast = 0,
            cooldown = 50,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132114,

            talent = "mighty_bash",
            
            handler = function ()
                applyDebuff( "target", "mighty_bash" )
            end,
        },
        

        moonfire = {
            id = 8921,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.06,
            spendType = "mana",
            
            startsCombat = true,
            texture = 136096,

            cycle = "moonfire",
            
            handler = function ()
                if not buff.moonkin_form.up and not buff.bear_form.up then unshift() end
                applyDebuff( "target", "moonfire" )
                gain( 3, "astral_power" )
            end,
        },
        

        moonkin_form = {
            id = 24858,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 136036,

            noform = "moonkin_form",
            essential = true,
            
            handler = function ()
                shift( "moonkin_form" )
            end,
        },
        

        new_moon = {
            id = 274281, 
            cast = 1,
            charges = 3,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",
            
            spend = -10,
            spendType = "astral_power",

            texture = 1392545,
            startsCombat = true,
            
            talent = "new_moon",
            bind = "full_moon",
            
            usable = function () return active_moon == "new_moon" end,
            handler = function ()
                spendCharges( "half_moon", 1 )
                spendCharges( "full_moon", 1 )

                active_moon = "half_moon"
            end,
        },
        

        prowl = {
            id = 5215,
            cast = 0,
            cooldown = 6,
            gcd = "spell",
            
            startsCombat = true,
            texture = 514640,
            
            usable = function () return time == 0 end,
            handler = function ()
                shift( "cat_form" )
                applyBuff( "prowl" )
                removeBuff( "shadowmeld" )
            end,
        },
        

        rake = {
            id = 1822,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 35,
            spendType = "energy",
            
            startsCombat = true,
            texture = 132122,

            talent = "feral_affinity",
            form = "cat_form",
            
            handler = function ()
                applyDebuff( "target", "rake" )
            end,
        },
        

        --[[ rebirth = {
            id = 20484,
            cast = 2,
            cooldown = 600,
            gcd = "spell",
            
            spend = 0,
            spendType = "rage",
            
            -- toggle = "cooldowns",

            startsCombat = true,
            texture = 136080,
            
            handler = function ()
            end,
        }, ]]
        

        regrowth = {
            id = 8936,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.14,
            spendType = "mana",
            
            startsCombat = false,
            texture = 136085,
            
            handler = function ()
                if buff.moonkin_form.down then unshift() end
                applyBuff( "regrowth" )
            end,
        },
        

        rejuvenation = {
            id = 774,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.11,
            spendType = "mana",
            
            startsCombat = false,
            texture = 136081,

            talent = "restoration_affinity",
            
            handler = function ()
                if buff.moonkin_form.down then unshift() end
                applyBuff( "rejuvenation" )
            end,
        },
        

        remove_corruption = {
            id = 2782,
            cast = 0,
            cooldown = 8,
            gcd = "spell",
            
            spend = 0.06,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135952,
            
            handler = function ()
            end,
        },
        

        renewal = {
            id = 108238,
            cast = 0,
            cooldown = 90,
            gcd = "spell",
            
            startsCombat = true,
            texture = 136059,

            talent = "renewal",
            
            handler = function ()
                -- unshift?
                gain( 0.3 * health.max, "health" )
            end,
        },
        

        --[[ revive = {
            id = 50769,
            cast = 10,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.04,
            spendType = "mana",
            
            startsCombat = true,
            texture = 132132,
            
            handler = function ()
            end,
        }, ]]
        

        rip = {
            id = 1079,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 30,
            spendType = "energy",
            
            startsCombat = true,
            texture = 132152,

            talent = "feral_affinity",
            form = "cat_form",

            usable = function () return combo_points.current > 0 end,
            handler = function ()
                spend( combo_points.current, "combo_points" )
                applyDebuff( "target", "rip" )
            end,
        },
        

        shred = {
            id = 5221,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 40,
            spendType = "energy",
            
            startsCombat = true,
            texture = 136231,

            talent = "feral_affinity",
            form = "cat_form",
            
            handler = function ()
                gain( 1, "combo_points" )
            end,
        },
        

        solar_beam = {
            id = 78675,
            cast = 0,
            cooldown = 60,
            gcd = "off",
            
            spend = 0.17,
            spendType = "mana",
            
            toggle = "interrupts",

            startsCombat = true,
            texture = 252188,
            
            usable = function () return target.casting end,
            handler = function ()
                if buff.moonkin_form.down then unshift() end
                interrupt()
            end,
        },
        

        solar_wrath = {
            id = 190984,
            cast = function () return haste * ( buff.solar_empowerment.up and 0.85 or 1 ) * 1.5 end,
            cooldown = 0,
            gcd = "spell",

            spend = -8,
            spendType = "astral_power",
            
            startsCombat = true,
            texture = 535045,
            
            handler = function ()
                if not buff.moonkin_form.up then unshift() end
                removeStack( "solar_empowerment" )
                removeBuff( "dawning_sun" )
                if azerite.sunblaze.enabled then applyBuff( "sunblaze" ) end
            end,
        },
        

        soothe = {
            id = 2908,
            cast = 0,
            cooldown = 10,
            gcd = "spell",
            
            spend = 0.06,
            spendType = "mana",
            
            startsCombat = true,
            texture = 132163,
            
            usable = function () return debuff.dispellable_enrage.up end,
            handler = function ()
                if buff.moonkin_form.down then unshift() end
                removeDebuff( "target", "dispellable_enrage" )
            end,
        },
        

        stag_form = {
            id = 210053,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 1394966,

            noform = "travel_form",
            handler = function ()
                shift( "stag_form" )
            end,
        },
        

        starfall = {
            id = 191034,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function ()
                if buff.oneths_overconfidence.up then return 0 end
                return talent.soul_of_the_forest.enabled and 40 or 50
            end,
            spendType = "astral_power",
            
            startsCombat = true,
            texture = 236168,
            
            handler = function ()
                addStack( "starlord", buff.starlord.remains > 0 and buff.starlord.remains or nil, 1 )
                removeBuff( "oneths_overconfidence" )
                if level < 116 and set_bonus.tier21_4pc == 1 then
                    applyBuff( "solar_solstice" )
                end
            end,
        },
        

        starsurge = {
            id = 78674,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function ()
                if buff.oneths_intuition.up then return 0 end
                return 40 - ( buff.the_emerald_dreamcatcher.stack * 5 )
            end,
            spendType = "astral_power",
            
            startsCombat = true,
            texture = 135730,
            
            handler = function ()
                addStack( "lunar_empowerment", nil, 1 )
                addStack( "solar_empowerment", nil, 1 )
                addStack( "starlord", buff.starlord.remains > 0 and buff.starlord.remains or nil, 1 )
                removeBuff( "oneths_intuition" )
                removeBuff( "sunblaze" )

                if pvptalent.moonkin_aura.enabled then
                    addStack( "moonkin_aura", nil, 1 )
                end

                if level < 116 and set_bonus.tier21_4pc == 1 then
                    applyBuff( "solar_solstice" )
                end
                if ( level < 116 and equipped.the_emerald_dreamcatcher ) then addStack( "the_emerald_dreamcatcher", 5, 1 ) end
            end,
        },
        

        stellar_flare = {
            id = 202347,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = -8,
            spendType = "astral_power",
            
            startsCombat = true,
            texture = 1052602,
            cycle = "stellar_flare",

            talent = "stellar_flare",
            
            handler = function ()
                applyDebuff( "target", "stellar_flare" )
            end,
        },
        

        sunfire = {
            id = 93402,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.12,
            spendType = "mana",
            
            startsCombat = true,
            texture = 236216,

            cycle = "sunfire",
            
            handler = function ()
                gain( 3, "astral_power" )
                applyDebuff( "target", "sunfire" )
            end,
        },
        

        swiftmend = {
            id = 18562,
            cast = 0,
            charges = 1,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",
            
            spend = 0.14,
            spendType = "mana",
            
            startsCombat = false,
            texture = 134914,

            talent = "restoration_affinity",            
            
            handler = function ()
                if buff.moonkin_form.down then unshift() end
                gain( health.max * 0.1, "health" )
            end,
        },
        
        -- May want to revisit this and split out swipe_cat from swipe_bear.
        swipe = {
            known = 213764,
            cast = 0,
            cooldown = function () return haste * ( buff.cat_form.up and 0 or 6 ) end,
            gcd = "spell",

            spend = function () return buff.cat_form.up and 40 or nil end,
            spendType = function () return buff.cat_form.up and "energy" or nil end,
            
            startsCombat = true,
            texture = 134296,

            talent = "feral_affinity",

            usable = function () return buff.cat_form.up or buff.bear_form.up end,
            handler = function ()
                if buff.cat_form.up then
                    gain( 1, "combo_points" )
                end
            end,

            copy = { 106785, 213771 }
        },
        

        thrash = {
            id = 106832,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = -5,
            spendType = "rage",
            
            cycle = "thrash_bear",
            startsCombat = true,
            texture = 451161,

            talent = "guardian_affinity",
            form = "bear_form",
            
            handler = function ()
                applyDebuff( "target", "thrash_bear", nil, debuff.thrash.stack + 1 )
            end,
        },
        

        tiger_dash = {
            id = 252216,
            cast = 0,
            cooldown = 45,
            gcd = "off",
            
            startsCombat = false,
            texture = 1817485,

            talent = "tiger_dash",
            
            handler = function ()
                shift( "cat_form" )
                applyBuff( "tiger_dash" )
            end,
        },
        

        thorns = {
            id = 236696,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            pvptalent = "thorns",
            
            spend = 0.12,
            spendType = "mana",
            
            startsCombat = false,
            texture = 136104,
            
            handler = function ()
                applyBuff( "thorns" )
            end,
        },
        

        travel_form = {
            id = 783,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132144,
            
            noform = "travel_form",
            handler = function ()
                shift( "travel_form" )
            end,
        },
        

        treant_form = {
            id = 114282,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132145,
            
            handler = function ()
                shift( "treant_form" )
            end,
        },
        

        typhoon = {
            id = 132469,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = true,
            texture = 236170,

            talent = "typhoon",
            
            handler = function ()
                applyDebuff( "target", "typhoon" )
                if target.distance < 15 then setDistance( target.distance + 5 ) end
            end,
        },
        

        warrior_of_elune = {
            id = 202425,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = true,
            texture = 135900,

            talent = "warrior_of_elune",

            usable = function () return buff.warrior_of_elune.down end,
            handler = function ()
                applyBuff( "warrior_of_elune", nil, 3 )
            end,
        },
        

        --[[ wartime_ability = {
            id = 264739,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1518639,
            
            handler = function ()
            end,
        }, ]]
        

        wild_charge = {
            id = function () return buff.moonkin_form.up and 102383 or 102401 end,
            known = 102401,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            startsCombat = false,
            texture = 538771,

            talent = "wild_charge",
            
            handler = function ()
                if buff.moonkin_form.up then setDistance( target.distance + 10 ) end
            end,

            copy = { 102401, 102383 }
        },
        

        wild_growth = {
            id = 48438,
            cast = 1.5,
            cooldown = 10,
            gcd = "spell",
            
            spend = 0.3,
            spendType = "mana",
            
            startsCombat = false,
            texture = 236153,

            talent = "wild_growth",
            
            handler = function ()
                unshift()
                applyBuff( "wild_growth" )
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,
    
        nameplates = false,
        nameplateRange = 8,
        
        damage = true,
        damageDots = false,
        damageExpiration = 6,
    
        potion = "potion_of_rising_death",
    
        package = "Balance",        
    } )


    spec:RegisterPack( "Balance", 20181215.2112, [[dCu6Maqiq0JajUeHQAtuvnkq4uQqRsfqVIqAwujDlrk2fL(LuvdJa6ysvwgvINjs10ub6AeK2giP6BeQY4iaNdKKADGKyEQGUNkAFGuhufGfsq9qcvYefPKlcssSrqssFKqLItksPSsrYojedLqfTucv4PGAQekxLqLQTsOsP9I0FLYGv1HrTyv6XumziDzsBwuFMk1OPk1PvA1IuQEnbA2iUTi2nWVjA4uXYL8COMUW1Hy7uv(ovX4bjLZtqSEQsMVuz)kM2JkgfgLdLkIlcSNa65spHADPxpxsx8OWHqCukSdBeKDRuyaNOuyHzcdmkf2HfcrYOuXOWyjszukS3r4GHk977EdVrUwJmPpEtqiCSsGP4C0hVjM(xI82)M50GQ(67uY8suCFXzPIdErX9fNIJwAvilAtyMWaJAXBIHcFrwsK2a0lfgLdLkIlcSNa65spHADPNafA6uygj8wwuy4nrCrH9Errva9sHrvSHcdL5fMjmWOZNwfYIoPGY8EhHdgQ0VV7n8g5AnYK(4nbHWXkbMIZrF8My6FjYB)BMtdQ6RVtjZlrX9fNLko4ff3xCkoAPvHSOnHzcdmQfVjMjfuMpTuJMC1A(Ec115DrG9eW8PzEx6bveyVj1KckZlU8MbUvmuzsbL5tZ8hakQIopSKW18cRCIDsbL5tZ8IlVzGBfD(Gl3A0288ggR45d58gHyiAl4YTgy7KckZNM5pa00ocou05X5wWLBnWZ7JRLVeD(SSMNrrLG5XcbemuZoPGY8Pz(dafvrNxChRZN2cnbBPWKfhyQyuyunZiKGkgvKEuXOWSjwjGcJLeUAxLtOWkGVefLkmnOI4cvmkSc4lrrPctHn1gATmf(IKZwd3wGXI4qHztSsaf2rgReqdQiPtfJcRa(suuQWuytTHwltHVi5S1WTfySiouy2eReqHVePeTLrkHqdQihKkgfwb8LOOuHPWMAdTwMcFrYzRHBlWyrCOWSjwjGcF1cRLGlWnnOIiuQyuyfWxIIsfMcBQn0Azk8fjNTgUTaJfXHcZMyLakmxggOTqwLccAqfbQtfJcRa(suuQWuytTHwltHVi5S1WTfySiouy2eReqHjRBVdClTJG6orbbnOIiEuXOWkGVefLkmf2uBO1Yu4lsoBnCBbglIdfMnXkbu48w6LiLO0GkIaOIrHvaFjkkvykSP2qRLPWxKC2A42cmwehkmBIvcOWmWO4OysZWecnOIavtfJcRa(suuQWuytTHwltHnsjbv6bynCBbgBPj8cWZd98PlqkmBIvcOWiyTTHMGPbvKEcKkgfMnXkbuypCvRSAYCtjiaLcRa(suuQW0GksVEuXOWkGVefLkmf2uBO1Yuy2lT2qTK1Nsesd7S1gwfWxIIoV)5HyEJusqLEa2fy4cWXkb2st4fGN)W5Dz(UU5nsjbv6bynkrXXYKgtw3Gefe2st4fGN)W575Y8hPWSjwjGcVaGw(4qPbvKEUqfJcRa(suuQWuytTHwltHzCumP5i9O18qFo)bfifMnXkbu4fy4cWXkb0GksV0PIrHvaFjkkvykSP2qRLPWmokM0CKE0AEOpN)GcCE)ZdX8qop7LwBOwY6tjcPHD2AdRc4lrrNVRB(lsoBjRpLiKg2zRnSioZFCE)ZdX8xKC2IdUiYc1Id2i48qFoVlZ31npKZhmrbHfhCrKfQvb8LOOZ31npKZ7JRLVe1YE1W45psHztSsaf2OefhltAmzDdsuqqdQi9oivmkSc4lrrPctHn1gATmfgI5Vi5S1WTfySioZ31nVrkjOspaRHBlWylnHxaEEONpDbo)X59ppJJIjnhPhTSOAEnBmp0NZ3lDkmBIvcOWzKsinzUPeeGsdQi9ekvmkSc4lrrPctHn1gATmfgI5Vi5S1WTfySioZ31nVrkjOspaRHBlWylnHxaEEONpDbo)X59ppJJIjnhPhTSOAEnBmp0NZ7IqPWSjwjGcNLLrBYCdWbsP0GkspOovmk8fjNBaorPW4GlISqPWkGVefLkmf2uBO1Yu4lsoBXbxezHAlnHxaE(dNxaZ7FEghftAospAnp0ZlaXJcZMyLakSHbgL0Ui5mnOI0t8OIrHvaFjkkvykSP2qRLPWqm)fjNT4GlISqT4Gnco)HZN(8DDZFrYzlo4IiluBPj8cWZd958cy(JZ7FESJsiTGl3AGNh6Z59X1YxIAX5wWLBnWZ7FEiMp4YTg2yt0wiBORoVOZ3B(JZFGZJDucPfC5wd88qpVrIJ5f)5DXkukmBIvcOW4GRmti0GkspbqfJcRa(suuQWuytTHwltHHy(GjkiS4GlISqTkGVefDE)ZdX8xKC2IdUiYc1Id2i48hoF6Z31n)fjNT4GlISqTLMWlapp0NZlG59p)fjNTCzyWAAoiemxwCWgbN)W5fW8hNVRBEiNpyIcclo4IiluRc4lrrN3)8qm)fjNTCzyWAAoiemxwCWgbN)W5fW8DDZFrYzRHBlWyrCM)48hN3)8yhLqAbxU1aBXbxzMqM)W59X1YxIAX5wWLBnWZ7F(lsoBjiaUAAIJ0JwjkiS4GncoVOZFrYzlws4QPjospALOGWId2i48ho)bN3)8xKC2ILeUAAIJ0JwjkiS4Gnco)HZN(8(N)IKZwccGRMM4i9OvIccloyJGZF48PpV)5HyEiN3hxlFjQL9QHXZ31npKZFrYzRHBlWyrCMVRBEiN3PuFwCWfgPCRZFC(UU5dUCRHn2eTfYg6QZF458kutniH2InrN)aNNXrXKMJ0JwZl(ZFqboFx38mokM0CKE0YIQ51SX8hoFV0PWSjwjGcJdUWiLBLgur6bvtfJcRa(suuQWuytTHwltHlnxk2B(s059ppeZZ4OysZr6rllQMxZgZd958cyE)ZNjsznpeZhC5wdBSjAlKn0vNx8NpwJGTyt05po)bop2rjKwWLBnWZd958hCErNh7Oesl4YTg459ppeZJDucPfC5wd88qpFV5fD(GjkiSHNf0sKsa2Qa(su0576Mhvg2ePeK3sTXAeCbUN)48(NhI5HCEFCT8LOw2RggpFx38qo)fjNTgUTaJfXz(UU5HCENs9zXiG8w68hN)ifMnXkbuymciVLsHncXq0wWLBnWur6rdQiUiqQyuyfWxIIsfMcBQn0AzkCP5sXEZxIoV)5HyEghftAospAzr18A2yEOpNxaZ7F(mrkR5Hy(Gl3AyJnrBHSHU68I)8XAeSfBIo)X5pW5XokH0cUCRbEEOpNxOZ7FEiMhY59X1YxIAzVAy88DDZd58xKC2A42cmweN576MhY5Dk1Nnrkb5T05po)rkmBIvcOWjsjiVLsHncXq0wWLBnWur6rdQiU0Jkgfwb8LOOuHPWMAdTwMcxAUuS38LOZ7FEiMNXrXKMJ0JwwunVMnMh6Z57L(8(NptKYAEiMp4YTg2yt0wiBORoV4pFSgbBXMOZFCEOpNhQpV)5HyEiN3hxlFjQL9QHXZ31npKZFrYzRHBlWyrCMVRBEiN3PuFwCOecxTmHlD(JZFKcZMyLakmoucHRwMWLsHncXq0wWLBnWur6rdQiU4cvmkSc4lrrPctHn1gATmfMXrXKMJ0JwwunVMnMh6Z57jukmBIvcOWa1tlrkb0GkIlPtfJcRa(suuQWuytTHwltHzCumP5i9OLfvZRzJ5H(CExekfMnXkbuyVzsULiLaAqfXLdsfJcRa(suuQWuytTHwltHzCumP5i9OLfvZRzJ5H(C(dkukmBIvcOWzecPLiLaAqfXfHsfJcRa(suuQWuytTHwltHVi5SfljC10ehPhTsuqyXbBeC(dNp959ppeZZ4OysZr6rllQMxZgZd9589eV576M)IKZwccGRMM4i9OvIccloyJGZFoF6ZFCE)ZdX8qm)fjNTE4Qwz1K5MsqaQfXz(UU5Vi5SLGa4QPjospALOGWI4mFx38yhLqAbxU1app0NZ7Y8(NhY5Vi5SfljC10ehPhTsuqyrCMVRBEFCT8LOw2RgkEE)Zd58xKC2IYEalWDdJaSioZFCE)ZdX8qoVpUw(sul7vdJNVRBEiN)IKZwd3wGXI4mFx38qmpKZ7uQplbbWvdh1kOoV)5HC(GjkiSlWWfGJvcSkGVefD(UU5Dk1NfljC18uC498hN)48DDZ7JRLVe1YE1W459p)fjNTgUTaJfXzE)Z7uQplws4Q5P4W75psHztSsafMGa4QHJAfuPbvexG6uXOWkGVefLkmf2uBO1YuyFCT8LOw2Rggp)HZN(8DDZd58xKC2A42cmweN576MhY5Dk1NfljC18uC4nfMnXkbuySKWvZtXH30GkIlIhvmkmBIvcOWyeqElLcRa(suuQW0GguyNsnYKlhuXOI0Jkgfwb8LOOuHPbvexOIrHvaFjkkvyAqfjDQyuyfWxIIsfMguroivmkSpMGOuy2lT2qT4OuwWf4UHdUW2IbcsHvaFjkkvykmBIvcOW(4A5lrPW(4Qb4eLcZE1WyAqfrOuXOW(ycIsHzV0Ad1IYEalWDdJaSfdeKcRa(suuQWuy2eReqH9X1YxIsH9XvdWjkfM9QHIPbveOovmkSpMGOuy2lT2qTCzyWAAoiemx2IbcsHvaFjkkvykmBIvcOW(4A5lrPW(4Qb4eLcZE1yhAqfr8OIrHvaFjkkvykS0HcJ1GcZMyLakSpUw(sukSpMGOuyHoFAMhI5dMOGWIdLq4QHwBoSkGVefD(UU5Hy(GjkiSlWWfGJvcSkGVefDE)ZhmrbHn8SGwIucWwfWxIIoV)5HCE2lT2qTCzyWAAoiemxwfWxIIo)X5poFAMhI5HCE2lT2qTCzyWAAoiemxwfWxIIoV)5HC(GjkiS4GlISqTkGVefD(JuyFC1aCIsHX5wWLBnW0GkIaOIrHztSsaforkbcUGwwwjuyfWxIIsfMgurGQPIrHvaFjkkvyAqfPNaPIrHztSsaf2rgReqHvaFjkkvyAqfPxpQyuy2eReqHXscxnpfhEtHvaFjkkvyAqdAqH9PfELaQiUiWEcONl96z7jEP7cf2dxGf4gtHtBjoYku05DzE2eRempzXb2oPOWoLmVeLcdL5fMjmWOZNwfYIoPGY8EhHdgQ0VV7n8g5AnYK(4nbHWXkbMIZrF8My6FjYB)BMtdQ6RVtjZlrX9fNLko4ff3xCkoAPvHSOnHzcdmQfVjMjfuMpTuJMC1A(Ec115DrG9eW8PzEx6bveyVj1KckZlU8MbUvmuzsbL5tZ8hakQIopSKW18cRCIDsbL5tZ8IlVzGBfD(Gl3A0288ggR45d58gHyiAl4YTgy7KckZNM5pa00ocou05X5wWLBnWZ7JRLVeD(SSMNrrLG5XcbemuZoPGY8Pz(dafvrNxChRZN2cnbBNutkOmpufOMAqcfD(RMLLoVrMC5y(R6Eby78hGXOobEEGeKgV5kjJqMNnXkb45LaIqStk2eReGToLAKjxooZegl4KInXkbyRtPgzYLdrp7NLs0jfBIvcWwNsnYKlhIE2NrCNOGGJvcMuqz(dWlT2qNxClxlFjkEsXMyLaS1PuJm5YHON99X1YxI6kGt0t2Rgg7QpMGONSxATHAXrPSGlWDdhCHTfdeCsXMyLaS1PuJm5YHON99X1YxI6kGt0t2Rgk2vFmbrpzV0Ad1IYEalWDdJaSfdeCsXMyLaS1PuJm5YHON99X1YxI6kGt0t2Rg74QpMGONSxATHA5YWG10CqiyUSfdeCsbL5HdUYmHmVV5HdUWiLBD(Gl3AmVbjK58KInXkbyRtPgzYLdrp77JRLVe1vaNON4Cl4YTgyxLoNynC1htq0tHMgicMOGWIdLq4QHwBoSkGVefTRdIGjkiSlWWfGJvcSkGVef1FWefe2WZcAjsjaBvaFjkQFizV0Ad1YLHbRP5GqWCzvaFjk6XJPbcizV0Ad1YLHbRP5GqWCzvaFjkQFidMOGWIdUiYc1Qa(su0Jtk2eReGToLAKjxoe9SFIuceCbTSSsMuqzEya7G9wgZx8Io)fjNv05Xbh45VAww68gzYLJ5VQ7fGNNbOZ7uAACKrSa3ZV45rLa1oPytSsa26uQrMC5q0Z(ya7G9wgnCWbEsXMyLaS1PuJm5YHON9DKXkbtk2eReGToLAKjxoe9Spws4Q5P4W7j1KckZdvbQPgKqrNx9PLqMp2eD(WBDE2eYA(fpp7JxcFjQDsXMyLa8jws4QDvozsXMyLaSON9DKXkbUU5ZlsoBnCBbglIZKInXkbyrp7FjsjAlJucX1nFErYzRHBlWyrCMuSjwjal6z)RwyTeCbUDDZNxKC2A42cmweNjfBIvcWIE2Nldd0wiRsbHRB(8IKZwd3wGXI4mPytSsaw0Z(K1T3bUL2rqDNOGW1nFErYzRHBlWyrCMuSjwjal6z)8w6LiLOUU5ZlsoBnCBbglIZKInXkbyrp7ZaJIJIjndtiUU5ZlsoBnCBbglIZKAsbL5fxPfEsXMyLaSON9rWABdnb76Mpnsjbv6bynCBbgBPj8cWqNUaNuSjwjal6zFpCvRSAYCtjiaDsXMyLaSON9xaqlFCOUU5t2lT2qTK1Nsesd7S1gwfWxII6hcJusqLEa2fy4cWXkb2st4fGp0LUoJusqLEawJsuCSmPXK1nirbHT0eEb4d75YXjfBIvcWIE2FbgUaCSsGRB(KXrXKMJ0JwqFEqboPytSsaw0Z(gLO4yzsJjRBqIccx38jJJIjnhPhTG(8Gc0peqYEP1gQLS(uIqAyNT2WQa(su0UUlsoBjRpLiKg2zRnSioh9dXfjNT4GlISqT4Gncc9PlDDqgmrbHfhCrKfQvb8LOODDq6JRLVe1YE1W4Jtk2eReGf9SFgPestMBkbbOUU5tiUi5S1WTfySioDDgPKGk9aSgUTaJT0eEbyOtxGh9Z4OysZr6rllQMxZgqF2l9jfBIvcWIE2pllJ2K5gGdKsDDZNqCrYzRHBlWyrC66msjbv6bynCBbgBPj8cWqNUap6NXrXKMJ0JwwunVMnG(0fHoPMuqzEyhfGQfEsXMyLaSON9nmWOK2fjNDfWj6jo4Iilux385fjNT4GlISqTLMWlaFOa8Z4OysZr6rlOfG4nPytSsaw0Z(4GRmtiUU5tiUi5SfhCrKfQfhSrWdtVR7IKZwCWfrwO2st4fGH(uah9JDucPfC5wdm0N(4A5lrT4Cl4YTgy)qeC5wdBSjAlKn0vfT3Xde7Oesl4YTgyOnsCi(Uyf6KInXkbyrp7JdUWiLB11nFcrWefewCWfrwOwfWxII6hIlsoBXbxezHAXbBe8W076Ui5SfhCrKfQT0eEbyOpfG)lsoB5YWG10CqiyUS4GncEOao21bzWefewCWfrwOwfWxII6hIlsoB5YWG10CqiyUS4GncEOa66Ui5S1WTfySiohp6h7Oesl4YTgylo4kZeYH(4A5lrT4Cl4YTgy)xKC2sqaC10ehPhTsuqyXbBeu0lsoBXscxnnXr6rRefewCWgbp8G(Vi5SfljC10ehPhTsuqyXbBe8W09FrYzlbbWvttCKE0krbHfhSrWdt3peq6JRLVe1YE1W4UoiVi5S1WTfySioDDq6uQplo4cJuU1JDDbxU1WgBI2czdD1dpvOMAqcTfBIEGmokM0CKE0s8pOa76yCumP5i9OLfvZRzJd7L(KAsbL5tlPy4jfBIvcWIE2hJaYBPUAeIHOTGl3AGp756Mplnxk2B(su)qW4OysZr6rllQMxZgqFka)zIuwqeC5wdBSjAlKn0vf)ync2InrpEGyhLqAbxU1ad95bff7Oesl4YTgy)qGDucPfC5wdm09enyIccB4zbTePeGTkGVefTRdvg2ePeK3sTXAeCbUp6hci9X1YxIAzVAyCxhKxKC2A42cmweNUoiDk1NfJaYBPhpoPytSsaw0Z(jsjiVL6QrigI2cUCRb(SNRB(S0CPyV5lr9dbJJIjnhPhTSOAEnBa9Pa8NjszbrWLBnSXMOTq2qxv8J1iyl2e94bIDucPfC5wdm0Nc1peq6JRLVe1YE1W4UoiVi5S1WTfySioDDq6uQpBIucYBPhpoPytSsaw0Z(4qjeUAzcxQRgHyiAl4YTg4ZEUU5ZsZLI9MVe1pemokM0CKE0YIQ51Sb0N9s3FMiLfebxU1WgBI2czdDvXpwJGTyt0JqFc19dbK(4A5lrTSxnmURdYlsoBnCBbglItxhKoL6ZIdLq4QLjCPhpoPMuqzEXnkqloKfEsXMyLaSON9bQNwIucCDZNmokM0CKE0YIQ51Sb0N9e6KInXkbyrp77ntYTePe46MpzCumP5i9OLfvZRzdOpDrOtk2eReGf9SFgHqAjsjW1nFY4OysZr6rllQMxZgqFEqHoPytSsaw0Z(eeaxnCuRGQRB(8IKZwSKWvttCKE0krbHfhSrWdt3pemokM0CKE0YIQ51Sb0N9eVUUlsoBjiaUAAIJ0JwjkiS4GncEM(r)qaXfjNTE4Qwz1K5MsqaQfXPR7IKZwccGRMM4i9OvIcclItxh2rjKwWLBnWqF6IFiVi5SfljC10ehPhTsuqyrC668X1YxIAzVAOy)qErYzlk7bSa3nmcWI4C0peq6JRLVe1YE1W4UoiVi5S1WTfySioDDqaPtP(SeeaxnCuRGQFidMOGWUadxaowjWQa(su0UoNs9zXscxnpfhEF8yxNpUw(sul7vdJ9FrYzRHBlWyrC87uQplws4Q5P4W7Jtk2eReGf9Spws4Q5P4WBx38PpUw(sul7vdJpm9UoiVi5S1WTfySioDDq6uQplws4Q5P4W7j1KckZdvLjKW7cz(SSMpr6ttuqmPytSsaw0Z(yeqElLcJDudvKEc0fAqdkfa]] )

    
end