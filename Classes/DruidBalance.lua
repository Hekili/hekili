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


    spec:RegisterStateExpr( "ap_check", function ()
        local a = this_action
        a = a and action[ this_action ]
        a = a and a.ap_check
    
        return a == true
    end )


    -- Simplify lookups for AP abilities consistent with SimC.
    local ap_checks = { 
        "force_of_nature", "full_moon", "half_moon", "lunar_strike", "moonfire", "new_moon", "solar_wrath", "starfall", "starsurge", "sunfire"
    }

    for i, lookup in ipairs( ap_checks ) do
        spec:RegisterStateExpr( lookup, function ()
            return action[ lookup ]
        end )
    end

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

            ap_check = function()
                return astral_power.current - action.force_of_nature.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,
            
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

            ap_check = function()
                return astral_power.current - action.full_moon.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,            
            
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
            
            ap_check = function()
                return astral_power.current - action.half_moon.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,
            
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

            ap_check = function()
                return astral_power.current - action.lunar_strike.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,            
            
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

            ap_check = function()
                return astral_power.current + 3 + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,                        
            
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
            
            ap_check = function()
                return astral_power.current - action.new_moon.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,            
            
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
            
            ap_check = function()
                return astral_power.current - action.solar_wrath.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,            
            
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
            
            ap_check = function()
                return astral_power.current - action.starfall.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,            
            
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
            
            ap_check = function()
                return astral_power.current - action.starsurge.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,            
            
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
            
            ap_check = function()
                return astral_power.current - action.stellar_flare.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,            
            
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
            
            ap_check = function()
                return astral_power.current - action.sunfire.cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
            end,            
            
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


    spec:RegisterPack( "Balance", 20181230.2112, [[dCe(LaqivHhbjCjIQYMOknkjPtjjwLQO8kivZIsLBju0UOYVucdtjvhdsAzefptjLPjuY1uskBJOk9nHsPXju4CkjjRtjPAEQICpvP9PK4GkjXcHuEirvyIevvxujjLnkuk0hfkfCsHsLvsvzNeLgkrv0svfv9uv1ujQCvHsrBvjjv7fP)kyWQCyulwPEmHjtjxM0ML4ZukJMQQtdSAHsvVwOA2iUTq2nOFtXWjYYv8COMUORdX2Pk(Us04vfvopKO1tPQ5lP2VutrLkh9BXPsLvM1rngOkZAR7KbvuLrMyr)jkLu6xIfXzBk9d5iL(rJjmuO0VeJsIHTOYr)ydYiu63FMs4vFXcBG0pY2jmrlWGiecNadumCjxGbrIfBIzVyx4yAPEwinMcGO4fYZrFEgyHxipF(G8piaRaAmHHc1Hbrc6FJaizSds30VfNkvwzwh1yGQmRTUtguxpgYSA0pJK(nd9)brYd63pWYsH0n9BPyb9JI(qJjmuO9j)dcWQ9HI(8NPeE1xSWgi9JSDct0cmicHWjWafdxYfyqKyXMy2l2foMwQNfsJPaikEH8C0NNbw4fYZNpi)dcWkGgtyOqDyqKO9HI(KFvOrBD6BT1TRpzwh1y0xm7tgux91L32x7df9jp8ZqBkE1BFOOVy23QyzPw99neE6dnLJCTpu0xm7tE4NH2uR(sESPzau6tWyf3xA6tGsbrdjp20e7AFOOVy23Qyf7rWPA1hUesESPjUpp8a4nr7RyM(ylldSpmkHj)CU2hk6lM9TkwwQvFXMyTVyxQryh9ta4etLJ(T0cJqsQCuzrLkh9ZIeyG0p2q4jSvoI(viVjQffnAsLvgQC0Vc5nrTOOr)IbK6ay6FJukobhaqHdrI(zrcmq6xYKadKMuzxJkh9RqEtulkA0VyaPoaM(3iLItWbau4qKOFwKadK(3eJXkuqgustQSXIkh9RqEtulkA0VyaPoaM(3iLItWbau4qKOFwKadK(36G1joaAJMuzxnQC0Vc5nrTOOr)IbK6ay6FJukobhaqHdrI(zrcmq6Nhbd1qAMrHjnPYkVu5OFfYBIArrJ(fdi1bW0)gPuCcoaGchIe9ZIeyG0pbyZFIdXEelBrkmPjv2ylvo6xH8MOwu0OFXasDam9VrkfNGdaOWHir)Sibgi9xaJUjgJfnPYgdQC0Vc5nrTOOr)IbK6ay6FJukobhaqHdrI(zrcmq6NHcfNdtccMqOjv2vfvo6xH8MOwu0OFXasDam9lmgILzj0j4aakCJgXaiUVv6BT1PFwKadK(rWAaKAeMMuzrDDQC0plsGbs)l5zaMjykbLGav6xH8MOwu0OjvwurLkh9RqEtulkA0VyaPoaM(z71bKQJa8OeugWsGbKofYBIA1N3(Q2NWyiwMLqhak4bYjWaDJgXaiUVN6tM(QR7tymelZsOtOefNaMeycWgmsHPB0igaX99uFOktFvOFwKadK(bqOoE4uPjvwuLHkh9RqEtulkA0VyaPoaM(zComjizwQtFR82xSwN(zrcmq6haf8a5eyG0KklQRrLJ(viVjQffn6xmGuhat)mohMeKml1PVvE7lwR3N3(Q23J(y71bKQJa8OeugWsGbKofYBIA1xDDFBKsXraEuckdyjWashIuFv6ZBFv7BJukoCYdXmwoCYI49TYBFY0xDDFp6lzIctho5HyglNc5nrT6RUUVh95HhaVjQJTpGX9vH(zrcmq6xOefNaMeycWgmsHjnPYIASOYr)kK3e1IIg9lgqQdGP)Q9TrkfNGdaOWHi1xDDFcJHyzwcDcoaGc3OrmaI7BL(wB9(Q0N3(WgcpHLdN(DSuq4xfXPFwKadK(lidkdMsqjiqLMuzrD1OYr)kK3e1IIg9lgqQdGP)Q9TrkfNGdaOWHi1xDDFcJHyzwcDcoaGc3OrmaI7BL(wB9(Q0N3(yPGWVkIt)Sibgi9xmJqdMsaYjYO0KklQYlvo6xH8MOwu0OFXasDam9Vrkfho5Hygl3OrmaI77P(IrFE77rFydHNWYHt)owki8RI40plsGbs)cgkusyJuk0)gPucqosPFCYdXmw0KklQXwQC0Vc5nrTOOr)IbK6ay6VAFBKsXHtEiMXYHtweVVN6BT(QR7BJukoCYdXmwUrJyae33kV9fJ(Q0N3(WskHesESPjUVvE7ZdpaEtuhUesESPjUpV9vTVKhBA6sqKgstWcO9HEFO2xL(EwFyjLqcjp20e33k9jm4Sp5RpzCRg9ZIeyG0po5PWecnPYIAmOYr)kK3e1IIg9lgqQdGP)Q9LmrHPdN8qmJLtH8MOw95TVQ9Trkfho5Hyglhozr8(EQV16RUUVnsP4WjpeZy5gnIbqCFR82xm6ZBFBKsXXJGHarqcHG5XHtweVVN6lg9vPV66(E0xYefMoCYdXmwofYBIA1N3(Q23gPuC8iyiqeKqiyEC4KfX77P(IrF119TrkfNGdaOWHi1xL(Q0N3(WskHesESPj2HtEkmH03t95HhaVjQdxcjp20e3N3(2iLIJGa5jOrsML6ePW0HtweVp07BJukoSHWtqJKml1jsHPdNSiEFp1xS6ZBFBKsXHneEcAKKzPorkmD4KfX77P(wRpV9TrkfhbbYtqJKml1jsHPdNSiEFp13A95TVQ99Opp8a4nrDS9bmUV66(E03gPuCcoaGchIuF1199OpPr94WjpyKXM2xL(QR7l5XMMUeePH0eSaAFp92N(CQaj1qcI0(EwFmohMeKml1Pp5RVyTEF1199OpSHWty5WPFhlfe(vrC6NfjWaPFCYdgzSP0KklQRkQC0Vc5nrTOOr)Sibgi9JrGfWO0VyaPoaM(hTmk2pVjAFE7RAFSuq4xfX7ZBFfIXm9vTVKhBA6sqKgstWcO9jF9vTpz67z9HLucj4NXP2xL(Q03Z6dlPesi5XMM4(w5TVy1h69HLucjK8yttCFE7RAFyjLqcjp20e33k9HAFO3xYefMUCjagImgi2PqEtuR(QR7ZYKUiJbwaJ6sGioaARVk95TVQ99Opp8a4nrDS9bmUV66(E03gPuCcoaGchIuF1199OpPr94WiWcy0(Q0xf6xGsbrdjp20etLfvAsLvM1PYr)kK3e1IIg9ZIeyG0FKXalGrPFXasDam9pAzuSFEt0(82x1(yPGWVkI3N3(keJz6RAFjp200LGinKMGfq7t(6RAFY03Z6dlPesWpJtTVk9vPVN1hwsjKqYJnnX9TYBFYBFE7RAFp6ZdpaEtuhBFaJ7RUUVh9TrkfNGdaOWHi1xDDFp6tAupUiJbwaJ2xL(Qq)cukiAi5XMMyQSOstQSYGkvo6xH8MOwu0OFwKadK(XPsi8ekeEu6xmGuhat)Jwgf7N3eTpV9vTpwki8RI495TVcXyM(Q2xYJnnDjisdPjyb0(KV(Q2Nm99S(WskHe8Z4u7RsFv6BL3(K3(82x1(E0NhEa8MOo2(ag3xDDFp6BJukobhaqHdrQV66(E0N0OEC4ujeEcfcpAFv6Rc9lqPGOHKhBAIPYIknPYkJmu5OFfYBIArrJ(fdi1bW0plfe(vrC6NfjWaPFOUmezmqAsLvM1OYr)kK3e1IIg9lgqQdGPFwki8RI40plsGbs)(zsjezmqAsLvMyrLJ(viVjQffn6xmGuhat)Suq4xfXPFwKadK(liesiYyG0KkRmRgvo6xH8MOwu0OFXasDam9Vrkfh2q4jOrsML6ePW0HtweVVN6BT(82x1(yPGWVkI3xDDFBKsXrqG8e0ijZsDIuy6WjlI33BFR1xL(82x1(Q23gPuCl5zaMjykbLGavhIuF119TrkfhbbYtqJKml1jsHPdrQV66(WskHesESPjUVvE7tM(823J(2iLIdBi8e0ijZsDIuy6qK6RUUpp8a4nrDS9blCFE77rFBKsXzXlHaOTagb6qK6RsFE7RAFp6ZdpaEtuhBFaJ7RUUVh9TrkfNGdaOWHi1xDDFv77rFsJ6XrqG8eW5aIR95TVh9LmrHPdaf8a5eyGofYBIA1xDDFsJ6XHneEclho93xL(Q0xDDFE4bWBI6y7dyCFE7BJukobhaqHdrQpV9jnQhh2q4jSC40FFvOFwKadK(jiqEc4CaXvAsLvg5Lkh9RqEtulkA0VyaPoaM(9WdG3e1X2hW4(EQV16RUUVh9TrkfNGdaOWHi1xDDFp6tAupoSHWty5WPF6NfjWaPFSHWty5WPFAsLvMylvo6NfjWaPFmcSagL(viVjQffnAst6xAuHjAZjvoQSOsLJ(viVjQffnAsLvgQC0Vc5nrTOOrtQSRrLJ(viVjQffnAsLnwu5OFfYBIArrJ(9WeeL(z71bKQdNJYXbqBbCYd2nmmo9ZIeyG0VhEa8MO0VhEcqosPF2(agttQSRgvo6xH8MOwu0OFpmbrPF2EDaP6S4Lqa0waJaDddJt)Sibgi97HhaVjk97HNaKJu6NTpyHPjvw5Lkh9RqEtulkA0VhMGO0pBVoGuD8iyiqeKqiyECddJt)Sibgi97HhaVjk97HNaKJu6NTpWs0KkBSLkh9RqEtulkA0VrI(XAs)Sibgi97HhaVjk97Hjik9hR(qVVQ9LmrHPlxcGHiJbIDkK3e1QpV9vTp2EDaP64rWqGiiHqW84uiVjQvF119LmrHPdN8qmJLtH8MOw9vPVk9fZ(Q23J(y71bKQJhbdbIGecbZJtH8MOw95TVh9LmrHPdN8qmJLtH8MOw95TVKjkmD4ujeEcwdOKofYBIA1xf63dpbihP0pUesESPjMMuzJbvo6NfjWaP)iJbghadfZer)kK3e1IIgnPYUQOYr)kK3e1IIgnPYI66u5OFwKadK(LmjWaPFfYBIArrJMuzrfvQC0plsGbs)ydHNWYHt)0Vc5nrTOOrtAst63JoyGbsLvM1rngOkdQRkhQYlQRr)l5bcG2W0FSlsYmPA1Nm9XIeyG9ra4e7AF0V0ykaIs)OOp0ycdfAFY)GaSAFOOp)zkHx9flSbs)iBNWeTadIqiCcmqXWLCbgejwSjM9IDHJPL6zH0ykaIIxiph95zGfEH885dY)GaScOXegkuhgejAFOOp5xfA0wN(wBD76tM1rng9fZ(Kb1vFD5T91(qrFYd)m0MIx92hk6lM9TkwwQvFFdHN(qt5ix7df9fZ(Kh(zOn1QVKhBAgaL(emwX9LM(eOuq0qYJnnXU2hk6lM9TkwXEeCQw9HlHKhBAI7ZdpaEt0(kMPp2YYa7dJsyYpNR9HI(IzFRILLA1xSjw7l2LAe21(AFOOVvTNtfiPA13wlMr7tyI2C23wTbGyxFRIqOsjUpObgt)8evqi9XIeyG4(mqckDTpwKade7KgvyI2C(wimoE7JfjWaXoPrfMOnNO)UOymwTpwKade7KgvyI2CI(7cgXwKctobgy7df9Tk2Rdi1(w15bWBIIBFSibgi2jnQWeT5e93fE4bWBIAhKJ0x2(agBNhMGOVS96as1HZr54aOTao5b7gggV9XIeyGyN0Oct0Mt0Fx4HhaVjQDqosFz7dwy78Wee9LTxhqQolEjeaTfWiq3WW4TpwKade7KgvyI2CI(7cp8a4nrTdYr6lBFGLSZdtq0x2EDaP64rWqGiiHqW84gggV9HI((jpfMq6ZtF)KhmYyt7l5XMM9jqstP0(yrcmqStAuHjAZj6Vl8WdG3e1oihPV4si5XMMy7msVynTZdtq03yHE1KjkmD5samezmqStH8MOwERY2RdivhpcgcebjecMhNc5nrTQRtMOW0HtEiMXYPqEtuRkvIz1hS96as1XJGHarqcHG5XPqEtulVpsMOW0HtEiMXYPqEtulVjtuy6WPsi8eSgqjDkK3e1Qs7JfjWaXoPrfMOnNO)UiYyGXbWqXmrTpu03hYsy)MSVHbw9Trkf1QpCYjUVTwmJ2NWeT5SVTAdaX9XqR(KgnMsMmbqB9bW9zzGQR9XIeyGyN0Oct0Mt0FxGHSe2Vjd4KtC7JfjWaXoPrfMOnNO)UqYKadS9XIeyGyN0Oct0Mt0FxGneEclho93(AFOOVvTNtfiPA1N6rhu2xcI0(s)AFSintFaCFShgq4nrDTpwKade)IneEcBLJAFSibgig93fsMeyG2bkVBKsXj4aakCisTpwKadeJ(7InXyScfKbL2bkVBKsXj4aakCisTpwKadeJ(7IToyDIdG2SduE3iLItWbau4qKAFSibgig93f8iyOgsZmkmTduE3iLItWbau4qKAFSibgig93feGn)joe7rSSfPW0oq5DJukobhaqHdrQ9XIeyGy0FxuaJUjgJLDGY7gPuCcoaGchIu7JfjWaXO)UGHcfNdtccMqSduE3iLItWbau4qKAFTpu0N8q(XTpwKadeJ(7ceSgaPgHTduEfgdXYSe6eCaafUrJyaeVYAR3(yrcmqm6VlwYZamtWuckbbQTpwKadeJ(7caeQJhov7aLx2EDaP6iapkbLbSeyaPtH8MOwERkmgILzj0bGcEGCcmq3OrmaIFsM6AHXqSmlHoHsuCcysGjaBWifMUrJyae)eQYuP9XIeyGy0FxaGcEGCcmq7aLxgNdtcsML6SYBSwV9XIeyGy0FxiuIItatcmbydgPW0oq5LX5WKGKzPoR8gR19w9bBVoGuDeGhLGYawcmG0PqEtuR66nsP4iapkbLbSeyaPdrQI3QBKsXHtEiMXYHtweFLxzQRFKmrHPdN8qmJLtH8MOw11p8WdG3e1X2hW4kTpwKadeJ(7IcYGYGPeuccuTduERUrkfNGdaOWHivxlmgILzj0j4aakCJgXaiEL1wVIxSHWty5WPFhlfe(vr82hlsGbIr)DrXmcnykbiNiJAhO8wDJukobhaqHdrQUwymelZsOtWbau4gnIbq8kRTEfVSuq4xfXBFTpu03xsHw6GBFSibgig93fcgkusyJuk2b5i9fN8qmJLDGY7gPuC4KhIzSCJgXai(Py49b2q4jSC40VJLcc)QiE7JfjWaXO)UaN8uycXoq5T6gPuC4KhIzSC4KfXFAT66nsP4WjpeZy5gnIbq8kVXOIxSKsiHKhBAIx51dpaEtuhUesESPj2B1KhBA6sqKgstWcOOJALNHLucjK8ytt8kcdoLpzCRw7JfjWaXO)UaN8GrgBQDGYB1KjkmD4KhIzSCkK3e1YB1nsP4WjpeZy5WjlI)0A11BKsXHtEiMXYnAedG4vEJH3nsP44rWqGiiHqW84WjlI)umQux)izIctho5HyglNc5nrT8wDJukoEemeicsiempoCYI4pfJ66nsP4eCaafoePkv8ILucjK8yttSdN8uyc5jp8a4nrD4si5XMMyVBKsXrqG8e0ijZsDIuy6WjlIJ(gPuCydHNGgjzwQtKcthozr8NIL3nsP4WgcpbnsYSuNifMoCYI4pTM3nsP4iiqEcAKKzPorkmD4KfXFAnVvF4HhaVjQJTpGX11p2iLItWbau4qKQRFinQhho5bJm20k11jp200LGinKMGfqF6vFovGKAibr6ZyComjizwQJ8fR1RRFGneEclho97yPGWVkI3(AFOOp53ihU9XIeyGy0FxGrGfWO2jqPGOHKhBAIFr1oq5D0YOy)8MOERYsbHFve3BHymt1KhBA6sqKgstWcOYxvzEgwsjKGFgNALkpdlPesi5XMM4vEJf6yjLqcjp20e7TkwsjKqYJnnXRGk6jtuy6YLayiYyGyNc5nrTQRTmPlYyGfWOUeiIdG2Q4T6dp8a4nrDS9bmUU(XgPuCcoaGchIuD9dPr94WiWcy0kvAFSibgig93frgdSag1obkfenK8ytt8lQ2bkVJwgf7N3e1Bvwki8RI4EleJzQM8yttxcI0qAcwav(QkZZWskHe8Z4uRu5zyjLqcjp20eVYR86T6dp8a4nrDS9bmUU(XgPuCcoaGchIuD9dPr94ImgybmALkTpwKadeJ(7cCQecpHcHh1obkfenK8ytt8lQ2bkVJwgf7N3e1Bvwki8RI4EleJzQM8yttxcI0qAcwav(QkZZWskHe8Z4uRuzLx51B1hE4bWBI6y7dyCD9JnsP4eCaafoeP66hsJ6XHtLq4jui8OvQ0(AFOOVydkuhondU9XIeyGy0Fxa1LHiJbAhO8YsbHFveV9XIeyGy0Fx4NjLqKXaTduEzPGWVkI3(yrcmqm6VlkiesiYyG2bkVSuq4xfXBFSibgig93feeipbCoG4QDGY7gPuCydHNGgjzwQtKcthozr8NwZBvwki8RI411BKsXrqG8e0ijZsDIuy6WjlI)UwfVvRUrkf3sEgGzcMsqjiq1HivxVrkfhbbYtqJKml1jsHPdrQUglPesi5XMM4vELX7JnsP4WgcpbnsYSuNifMoeP6Ap8a4nrDS9blS3hBKsXzXlHaOTagb6qKQ4T6dp8a4nrDS9bmUU(XgPuCcoaGchIuDD1hsJ6XrqG8eW5aIREFKmrHPdaf8a5eyGofYBIAvxlnQhh2q4jSC40FLk11E4bWBI6y7dyS3nsP4eCaafoejVsJ6XHneEclho9xP9XIeyGy0FxGneEclho9BhO86HhaVjQJTpGXpTwD9JnsP4eCaafoeP66hsJ6XHneEclho93(AFOOVyJmHK(hK(kMPViJhnsHz7JfjWaXO)UaJalGrPFSKkOYI66YqtAsP]] )

    
end