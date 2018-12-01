ZZHousingInventory = ZZHousingInventory or {}
-- crate names
local STORM_ATRONACH    = "Storm Atronach"
local REAPERS_HARVEST   = "Reaper's Harvest"
local HOLLOWJACK        = "Hollowjack"
local DWARVEN           = "Dwarven"
local WILD_HUNT         = "Wild Hunt"
local FLAME_ATRONACH    = "Flame Atronach"
local PSIJIC_VAULT      = "Psijic Vault"
local OUROBOROS         = "Ouroboros"
local SCALECALLER       = "Scalecaller"

-- Collectibles --------------------------------------------------------------
--
-- collectible_id   How to identify which collectible this is.
--                  Fodder for GetCollectibleInfo() and other ZOS API calls.
-- name             EN English name. THere are some duplicates!
-- crowns           If this was ever offered for sale in the crown store, for how much?
-- crate            If this was ever available in a loot crate, which one?
--                  (Doesn't really matter, but keeping around for now anyway.)
-- gold             If this was ever for sale for gold (houses often are!), how much?
-- house_id         house_id for ZOS API if this is a house.
-- vouchers         Storage: purchasable by writ vouchers
-- tel_var          Storage: purchasable by Tel Var stones.
--
ZZHousingInventory.COLLECTIBLES = {
--                                                                         , crowns =      , crate =                 , gold =        , house_id =    }
  { collectible_id =    1, name = "Palomino Horse"                         , crowns =   900, crate = STORM_ATRONACH  }
, { collectible_id =    2, name = "Sorrel Horse"                                                                     , gold =  10000 }
, { collectible_id =    3, name = "Brown Paint Horse"                                                                , gold =  42700 }
, { collectible_id =    4, name = "Bay Dun Horse"                                                                    , gold =  42700 }
, { collectible_id =    5, name = "Midnight Steed"                                                                   , gold =  42700 }
, { collectible_id =    6, name = "Imperial Horse"                                                                   } -- part of Imperial Edition
, { collectible_id =    7, name = "Nibenay Mudcrab"                                                                  } -- part of Imperial Edition
, { collectible_id =    8, name = "Razak's Opus"                                                                     } -- Razak's Wheel reward
, { collectible_id =    9, name = "Pony Guar"                                                                        } -- Pony Guar Plush Toy
, { collectible_id =   10, name = "Crony Scrib"                                                                      } -- part of Fighters Guild Journeyman figure
, { collectible_id =   11, name = "Imgakin Monkey"                                                                   } -- PC Beta reward
, { collectible_id =   12, name = "Whiterun Wolfhound"                     , crowns =   400                          } -- also in some starter pack bundles
, { collectible_id =   13, name = "Rufous Mudcrab"                                                                   } -- convention perk
, { collectible_id =   14, name = "Bristlegut Piglet"                                                                } -- convention perk
, { collectible_id =   15, name = "Frisky Scrib"                                                                     }
, { collectible_id =   16, name = "High Hrothgar Wraith"                                                             } -- loyalty 3 months
, { collectible_id =   17, name = "Loyal Dwarven Sphere"                                                             } -- loyalty 6 months
, { collectible_id =   18, name = "Green Narsis Guar"                                      , crate = DWARVEN         } -- 2015 Black Fredas crown sale, too
, { collectible_id =   19, name = "Golden Eye Guar"                        , crowns =  1300                          }
, { collectible_id =   20, name = "Banded Guar Charger"                    , crowns =  1300                          }
, { collectible_id =   21, name = "Tessellated Guar"                       , crowns =  1300                          }
, { collectible_id =   22, name = "Senche-Leopard"                         , crowns =  2500, crate = FLAME_ATRONACH  }
, { collectible_id =   23, name = "Clouded Senche-Leopard"                 , crowns =  2500                          }
, { collectible_id =   24, name = "Black Senche-Panther"                   , crowns =  2500                          }
, { collectible_id =   25, name = "Senche-Lioness"                         , crowns =  1800                          }
, { collectible_id =   26, name = "Banekin"                                , crowns =   700, crate = WILD_HUNT       }
, { collectible_id =   27, name = "Blackwood Monkey"                                                                 } -- ?
, { collectible_id =   28, name = "Vermilion Scuttler"                                                               } -- Explorers Pack preorder
, { collectible_id =   29, name = "Bravil Retriever"                       , crowns =   400                          }
, { collectible_id =   30, name = "Helstrom Ancestor Lizard"               , crowns =   400, crate = STORM_ATRONACH  }
, { collectible_id =   31, name = "Daedric Scamp"                          , crowns =   700, crate = STORM_ATRONACH  }
, { collectible_id =   32, name = "Windhelm Wolfhound"                                                               }
, { collectible_id =   33, name = "Housecat"                               , crowns =   400, crate = SCALECALLER     }
, { collectible_id =   35, name = "Striped Senche-Tiger"                                                             } -- Loyalty reward, 300 days
, { collectible_id =   36, name = "Dovah-Fly"                                                                        }
, { collectible_id =   37, name = "Dovah-Fly"                                                                        }
, { collectible_id =   41, name = "Regal Dovah-Fly"                                        , crate = FLAME_ATRONACH  }
, { collectible_id =   43, name = "Daedrat"                                , crowns =   500                          }
, { collectible_id =   55, name = "White Mane Horse"                       , crowns =   900                          }
, { collectible_id =   56, name = "Dapple Gray Palfrey"                    , crowns =   900                          }
, { collectible_id =   57, name = "Piebald Destrier"                       , crowns =   900                          }
, { collectible_id =   58, name = "Gray Yokudan Charger"                   , crowns =   900                          }
, { collectible_id =   59, name = "Nightmare Courser"                      , crowns =  2500                          }
, { collectible_id =   61, name = "Bantam Guar"                            , crowns =   400                          } -- Adventurer Pack
, { collectible_id =   62, name = "Alik'r Dune-Hound"                      , crowns =   400                          }
, { collectible_id =   63, name = "Striped Senche-Panther"                 , crowns =   700                          }
, { collectible_id =   67, name = "Amber Ash Hopper"                       , crowns =   700                          }
, { collectible_id =   68, name = "Deep-Moss Ash Hopper"                                   , crate = DWARVEN         }
, { collectible_id =   69, name = "Ruby Shroom Shalk"                                      , crate = PSIJIC_VAULT    }
, { collectible_id =   77, name = "Blue-Cap Shroom Shalk"                                  , crate = DWARVEN         }
, { collectible_id =   78, name = "Bitter Coast Cliff Strider"             , crowns =   700                          }
, { collectible_id =   86, name = "Shornhelm Shepherd"                     , crowns =   400, crate = STORM_ATRONACH  }
, { collectible_id =   88, name = "Freckled Guar"                          , crowns =   700                          }
, { collectible_id =   89, name = "Gold-Cap Shroom Shalk"                                  , crate = SCALECALLER     }
, { collectible_id =   90, name = "Boralis Gray Wolf Pup"                                                            } -- ?
, { collectible_id =   91, name = "Striated Pony Guar"                     , crowns =   400                          }
, { collectible_id =   92, name = "White River Ice Wolf Pup"               , crowns =  1000, crate = FLAME_ATRONACH  }
, { collectible_id =   93, name = "Frost Mare"                             , crowns =  3000, crate = STORM_ATRONACH  }
, { collectible_id =  102, name = "Doom Wolf Pup"                                          , crate = WILD_HUNT       }
, { collectible_id =  104, name = "Skeletal Pony Guar"                                                               } -- ?
, { collectible_id =  105, name = "Plague Husk Skeletal Wolf"                                                        }
, { collectible_id =  106, name = "Cinder Skeletal Horse"                                                            }
, { collectible_id =  107, name = "Frost Draugr Skeletal Wolf"                                                       }
, { collectible_id =  111, name = "Fennec Fox"                             , crowns =   700, crate = DWARVEN         }
, { collectible_id =  112, name = "Purple Daggerback"                                      , crate = STORM_ATRONACH  }
, { collectible_id =  113, name = "Mind-Shriven Horse"                     , crowns =  2200, crate = STORM_ATRONACH  }
, { collectible_id =  114, name = "Red Pit Wolf Pup"                                       , crate = STORM_ATRONACH  }
, { collectible_id =  133, name = "Abecean Ratter Cat"                     , crowns =  400                           }
, { collectible_id =  134, name = "Senchal Striped Cat"                                                              } -- ?
, { collectible_id =  135, name = "Necrom Ghostgazer Cat"                                                            } -- ?
, { collectible_id =  136, name = "Markarth Bear-Dog"                                                                } -- crown store, price unknown
, { collectible_id =  143, name = "Baby Netch"                                             , crate = WILD_HUNT       }
, { collectible_id =  144, name = "Ninendava Sacred Goat"                                  , crate = DWARVEN         }
, { collectible_id =  145, name = "Bal Foyen Nix-Hound"                    , crowns =   400, crate = DWARVEN         }
, { collectible_id =  149, name = "Stonefire Scamp"                                                                  } -- Imperial Sewers event reward
, { collectible_id =  150, name = "Imperial War Mastiff"                                                             } -- Ten Million Stories reward
, { collectible_id =  151, name = "Cave Bear"                              , crowns =  1800                          } -- also part of Orsinium DLC Collector's Edition
, { collectible_id =  153, name = "Copperback Bear-Dog"                                    , crate = DWARVEN         }
, { collectible_id =  155, name = "Fiendroth"                              , crowns =   700                          }
, { collectible_id =  156, name = "Pocket Mammoth"                         , crowns =   700                          }
, { collectible_id =  157, name = "Dragontail Goat"                        , crowns =   400                          }
, { collectible_id =  158, name = "Sanguine's Black Goat"                  , crowns =   400                          }
, { collectible_id =  159, name = "Chub Loon"                                              , crate = STORM_ATRONACH  }
, { collectible_id =  160, name = "Echalette"                                                                        } -- free with Orsinium
, { collectible_id =  163, name = "Necrotic Hoarvor"                                                                 } -- Imperial City achievement reward
, { collectible_id =  164, name = "Skeletal Horse"                                         , crate = REAPERS_HARVEST }
, { collectible_id =  165, name = "Skeletal Senche"                                        , crate = REAPERS_HARVEST }
, { collectible_id =  166, name = "Skeletal Guar"                                          , crate = REAPERS_HARVEST }
, { collectible_id =  173, name = "Zombie Horse"                           , crowns =  1200, crate = HOLLOWJACK      }
, { collectible_id =  177, name = "Snow Bear"                              , crowns =  2500                          }
, { collectible_id =  178, name = "Black Bear"                             , crowns =  2500                          }
, { collectible_id =  189, name = "Skeletal Bear"                                          , crate = REAPERS_HARVEST }
, { collectible_id =  190, name = "Black Bear Cub"                         , crowns =  1000, crate = REAPERS_HARVEST }
, { collectible_id =  191, name = "Cave Bear Cub"                          , crowns =   700                          }
, { collectible_id =  192, name = "Psijic Domino Pig"                      , crowns =   700                          }
, { collectible_id =  193, name = "Snow Bear Cub"                          , crowns =  1000                          }
, { collectible_id =  212, name = "Imperial War Dog Unarmored"                                                       }
, { collectible_id =  221, name = "Black Mask Bear-Dog"                                    , crate = STORM_ATRONACH  }
, { collectible_id =  222, name = "Mossy Netch Calf"                                       , crate = DWARVEN         }
, { collectible_id =  231, name = "Pale Velothi Guar"                      , crowns =  2500, crate = DWARVEN         }
, { collectible_id =  232, name = "Moonlight Senche-Tiger"                 , crowns =   700                          }
, { collectible_id =  233, name = "Hammerfell Camel"                       , crowns =  1800                          }
, { collectible_id =  234, name = "Zeht's Cloud Camel"                     , crowns =  1900                          }
, { collectible_id =  235, name = "Black Camel of Ill Omen"                , crowns =  2500, crate = FLAME_ATRONACH  }
, { collectible_id =  242, name = "Kindlespit Dragon Frog"                                                           } -- crown store, occasional
, { collectible_id =  243, name = "Tangerine Dragon Frog"                                  , crate = STORM_ATRONACH  }
, { collectible_id =  244, name = "Blue Oasis Dragon Frog"                 , crowns =   700, crate = WILD_HUNT       }
, { collectible_id =  253, name = "Rosy Netch Calf"                                        , crate = STORM_ATRONACH  }
, { collectible_id =  260, name = "Senche-Lion Cub"                                        , crate = SCALECALLER     }
, { collectible_id =  261, name = "Dro-m'Athra Senche"                     , crowns =  4000, crate = DWARVEN         }
, { collectible_id =  262, name = "Masked Bear"                            , crowns =  2500, crate = FLAME_ATRONACH  }
, { collectible_id =  263, name = "Sabre Cat"                              , crowns =  2500                          }
, { collectible_id =  265, name = "Pride-King Lion"                        , crowns =  1800                          }
, { collectible_id =  266, name = "Skeletal Camel"                                         , crate = REAPERS_HARVEST }
, { collectible_id =  267, name = "Tythis Andromo, the Banker"             , crowns =  5000                          }
, { collectible_id =  268, name = "Sylvan Nixad"                           , crowns =   700, crate = PSIJIC_VAULT    }
, { collectible_id =  269, name = "Turquoise Nixad"                        , crowns   = 700                          }
, { collectible_id =  270, name = "Orchid Nixad"                                           , crate = STORM_ATRONACH  }
, { collectible_id =  290, name = "Highland Wolf"                          , crowns =  1800                          }
, { collectible_id =  291, name = "Doom Wolf"                              , crowns =  2500                          } -- Also PC/Mac code w/Elder Scrolls:Legends
, { collectible_id =  292, name = "Ice Wolf"                               , crowns =  2500, crate = FLAME_ATRONACH  }
, { collectible_id =  293, name = "Wild Hunt Horse"                                        , crate = WILD_HUNT       }
, { collectible_id =  294, name = "Wild Hunt Guar"                                         , crate = WILD_HUNT       }
, { collectible_id =  295, name = "Wild Hunt Senche"                                       , crate = WILD_HUNT       }
, { collectible_id =  296, name = "Wild Hunt Bear"                                         , crate = WILD_HUNT       }
, { collectible_id =  297, name = "Wild Hunt Camel"                                        , crate = WILD_HUNT       }
, { collectible_id =  298, name = "Wild Hunt Wolf"                                         , crate = WILD_HUNT       }
, { collectible_id =  299, name = "Skeletal Wolf"                                          , crate = REAPERS_HARVEST }
, { collectible_id =  300, name = "Pirharri the Smuggler"                                                            } -- Completing Thieves Guild quest line
, { collectible_id =  301, name = "Nuzhimeh the Merchant"                  , crowns =  5000                          }
, { collectible_id =  303, name = "Sabre Leopard Cub"                                                                } -- ?
, { collectible_id =  304, name = "Alliance War Dog"                       , crowns =  1000                          }
, { collectible_id =  305, name = "Black Mane Lion"                                        , crate = STORM_ATRONACH  }
, { collectible_id =  313, name = "White Lion"                                                                       }
, { collectible_id =  314, name = "Hearthfire Kagouti"                     , crowns =  4000                          }
, { collectible_id =  324, name = "Northern Lynx"                          , crowns =   700, crate = REAPERS_HARVEST }
, { collectible_id =  325, name = "Colovian Badger"                        , crowns =   700, crate = REAPERS_HARVEST }
, { collectible_id =  326, name = "Red Pit Wolf"                                           , crate = STORM_ATRONACH  }
, { collectible_id =  357, name = "Snowy Sabre Cat Cub"                                                              } -- ?
, { collectible_id =  360, name = "Jackal"                                                                           } -- free with Abah's Landing
, { collectible_id =  364, name = "Clockwork Shalk"                                        , crate = DWARVEN         }
, { collectible_id =  365, name = "Alliance War Horse"                     , crowns =  2500                          }
, { collectible_id =  391, name = "Sep Adder"                              , crowns =   700                          }
, { collectible_id =  392, name = "Heartland Brindle Badger"                                                         } -- ?
, { collectible_id =  393, name = "M'aiq the Badger"                                                                 } -- ?
, { collectible_id =  394, name = "Black Cat"                              , crowns =   700                          }
, { collectible_id =  395, name = "Kagouti"                                , crowns =  2500                          }
, { collectible_id =  396, name = "Allaria Erwen the Exporter"                                                       } -- ?
, { collectible_id =  397, name = "Cassus Andronicus the Mercenary"                                                  } -- ?
, { collectible_id =  400, name = "Storm Atronach Horse"                                   , crate = STORM_ATRONACH  }
, { collectible_id =  402, name = "Storm Atronach Guar"                                    , crate = STORM_ATRONACH  }
, { collectible_id =  403, name = "Storm Atronach Senche"                                  , crate = STORM_ATRONACH  }
, { collectible_id =  404, name = "Storm Atronach Camel"                                   , crate = STORM_ATRONACH  }
, { collectible_id =  405, name = "Storm Atronach Bear"                                    , crate = STORM_ATRONACH  }
, { collectible_id =  406, name = "Clouded Senche-Leopard Cub"                             , crate = STORM_ATRONACH  }
, { collectible_id =  443, name = "Hist Guar"                              , crowns =  1500                          } -- also Shadows of the Hist Collector's Bundle
, { collectible_id =  476, name = "Haj Mota Hatchling"                     , crowns =  1000                          }
, { collectible_id =  477, name = "Desert Lynx"                            , crowns =   700                          }
, { collectible_id =  478, name = "Infernal Sep Adder"                     , crowns =  1000                          }
, { collectible_id =  483, name = "Dark Moons Lynx"                                         , crate = WILD_HUNT      }
, { collectible_id =  484, name = "Dwarven War Dog"                                                                  } -- Discovery Pack, Morrowind
, { collectible_id =  485, name = "Silt Strider A"                                                                   }
, { collectible_id =  486, name = "Silt Strider B"                                                                   }
, { collectible_id =  591, name = "Great Elk"                              , crowns =  4500                          }
, { collectible_id =  592, name = "Dozen-Banded Vvardvark"                                                           } -- Morrowind owners
, { collectible_id =  607, name = "Cobalt Sep Adder"                                       , crate = WILD_HUNT       }
, { collectible_id =  608, name = "Storm Atronach Wolf"                                    , crate = STORM_ATRONACH  }
, { collectible_id =  609, name = "Black Senche-Lion"                      , crowns =  2500                          }
, { collectible_id =  739, name = "Imperial War Horse"                     , crowns =  2500                          }
, { collectible_id =  740, name = "Arctic Fennec Fox"                                      , crate = FLAME_ATRONACH  }
, { collectible_id =  741, name = "Dusky Fennec Fox"                                                                 } -- Daily Rewards
, { collectible_id =  742, name = "Tuxedo Bear"                            , crowns =  1900                          }
, { collectible_id =  743, name = "Senche-Tiger Cub"                                                                 }
, { collectible_id =  744, name = "Senche Cub (White Lion)"                                                          }
, { collectible_id =  745, name = "Black Senche-Panther Kitten"                            , crate = WILD_HUNT       }
, { collectible_id =  746, name = "Dro-m'Athra Senche Cub"                                 , crate = DWARVEN         }
, { collectible_id =  747, name = "Senche Cub (White Tiger)"                                                         }
, { collectible_id =  748, name = "Senche Cub (Tiger)"                                                               }
, { collectible_id =  749, name = "Senche-Leopard Cub"                                     , crate = FLAME_ATRONACH  }
, { collectible_id =  750, name = "Striped Senche-Panther Cub"                                                       } -- ?
, { collectible_id =  752, name = "Ascadian Cliff Strider"                                                           } -- ?
, { collectible_id =  761, name = "Craglorn Welwa"                         , crowns =   700                          }
, { collectible_id =  762, name = "Great Dark Stag"                        , crowns =  4000                          }
, { collectible_id =  763, name = "Nightfall Sabre Cat"                    , crowns =  2500                          }
, { collectible_id =  764, name = "Sabre Cat Cub"                                          , crate = SCALECALLER     }
, { collectible_id =  765, name = "Nightfall Sabre Cat Cub"                                                          } -- ?
, { collectible_id =  766, name = "Black Morthal Mastiff"                                                            } -- ?
, { collectible_id =  767, name = "Tan Morthal Mastiff"                                    , crate = SCALECALLER     }
, { collectible_id =  768, name = "Gray Morthal Mastiff"                                   , crate = PSIJIC_VAULT    }
, { collectible_id =  769, name = "Hearthfire Hatchling"                   , crowns =  1200                          }
, { collectible_id =  785, name = "Ancestor Moth Swarm"                                    , crate = WILD_HUNT       }
, { collectible_id =  786, name = "Devoted Torchbug"                                                                 } -- streamer/ZOS reward
, { collectible_id = 1060, name = "Mara's Kiss Public House"               , crowns =   nil                          , gold =    3000, house_id =  1 }
, { collectible_id = 1061, name = "The Rosy Lion"                          , crowns =   nil                          , gold =    3000, house_id =  2 }
, { collectible_id = 1062, name = "The Ebony Flask Inn Room"               , crowns =   nil                          , gold =    3000, house_id =  3 }
, { collectible_id = 1063, name = "Barbed Hook Private Room"               , crowns =   600                          , gold =   11000, house_id =  4 }
, { collectible_id = 1064, name = "Sisters of the Sands Apartment"         , crowns =   640                          , gold =   12000, house_id =  5 }
, { collectible_id = 1065, name = "Flaming Nix Deluxe Garret"              , crowns =   660                          , gold =   13000, house_id =  6 }
, { collectible_id = 1066, name = "Black Vine Villa"                       , crowns =  2250                          , gold =   54000, house_id =  7 }
, { collectible_id = 1067, name = "Cliffshade"                             , crowns =  3600                          , gold =  255000, house_id =  8 }
, { collectible_id = 1068, name = "Mathiisen Manor"                        , crowns =  6400                          , gold = 1025000, house_id =  9 }
, { collectible_id = 1069, name = "Humblemud"                              , crowns =  2600                          , gold =   40000, house_id = 10 }
, { collectible_id = 1070, name = "The Ample Domicile"                     , crowns =  3520                          , gold =  195000, house_id = 11 }
, { collectible_id = 1071, name = "Stay-Moist Mansion"                     , crowns =  5500                          , gold =  760000, house_id = 12 }
, { collectible_id = 1072, name = "Snugpod"                                , crowns =  2150                          , gold =   45000, house_id = 13 }
, { collectible_id = 1073, name = "Bouldertree Refuge"                     , crowns =  3500                          , gold =  190000, house_id = 14 }
, { collectible_id = 1074, name = "The Gorinir Estate"                     , crowns =  5600                          , gold =  780000, house_id = 15 }
, { collectible_id = 1075, name = "Captain Margaux's Place"                , crowns =  2300                          , gold =   56000, house_id = 16 }
, { collectible_id = 1076, name = "Ravenhurst"                             , crowns =  3500                          , gold =  260000, house_id = 17 }
, { collectible_id = 1077, name = "Gardner House"                          , crowns =  5700                          , gold = 1015000, house_id = 18 }
, { collectible_id = 1078, name = "Kragenhome"                             , crowns =  2500                          , gold =   69000, house_id = 19 }
, { collectible_id = 1079, name = "Velothi Reverie"                        , crowns =  4200                          , gold =  323000, house_id = 20 }
, { collectible_id = 1080, name = "Quondam Indorilia"                      , crowns =  6100                          , gold = 1265000, house_id = 21 }
, { collectible_id = 1081, name = "Moonmirth House"                        , crowns =  2200                          , gold =   50000, house_id = 22 }
, { collectible_id = 1082, name = "Sleek Creek House"                      , crowns =  4400                          , gold =  335000, house_id = 23 }
, { collectible_id = 1083, name = "Dawnshadow"                             , crowns =  6200                          , gold = 1275000, house_id = 24 }
, { collectible_id = 1084, name = "Cyrodilic Jungle House"                 , crowns =  2550                          , gold =   71000, house_id = 25 }
, { collectible_id = 1085, name = "Domus Phrasticus"                       , crowns =  4000                          , gold =  295000, house_id = 26 }
, { collectible_id = 1086, name = "Strident Springs Demesne"               , crowns =  6300                          , gold = 1280000, house_id = 27 }
, { collectible_id = 1087, name = "Autumn's-Gate"                          , crowns =  2350                          , gold =   60000, house_id = 28 }
, { collectible_id = 1088, name = "Grymharth's Woe"                        , crowns =  3800                          , gold =  280000, house_id = 29 }
, { collectible_id = 1089, name = "Old Mistveil Manor"                     , crowns =  5800                          , gold = 1020000, house_id = 30 }
, { collectible_id = 1090, name = "Hammerdeath Bungalow"                   , crowns =  2400                          , gold =   65000, house_id = 31 }
, { collectible_id = 1091, name = "Mournoth Keep"                          , crowns =  4300                          , gold =  325000, house_id = 32 }
, { collectible_id = 1092, name = "Forsaken Stronghold"                    , crowns =  6400                          , gold = 1285000, house_id = 33 }
, { collectible_id = 1093, name = "Twin Arches"                            , crowns =  2600                          , gold =   73000, house_id = 34 }
, { collectible_id = 1094, name = "House of the Silent Magnifico"          , crowns =  4100                          , gold =  320000, house_id = 35 }
, { collectible_id = 1095, name = "Hunding's Palatial Hall"                , crowns =  6500                          , gold = 1295000, house_id = 36 }
, { collectible_id = 1096, name = "Serenity Falls Estate"                  , crowns = 10000                          , gold = 3775000, house_id = 37 }
, { collectible_id = 1097, name = "Daggerfall Overlook"                    , crowns = 11000                          , gold = 3780000, house_id = 38 }
, { collectible_id = 1098, name = "Ebonheart Chateau"                      , crowns = 12000                          , gold = 3785000, house_id = 39 }
, { collectible_id = 1099, name = "Grand Topal Hideaway"                   , crowns = 15000                          , gold =     nil, house_id = 40 }
, { collectible_id = 1100, name = "Earthtear Cavern"                       , crowns = 13000                          , gold =     nil, house_id = 41 }
, { collectible_id = 1110, name = "Bust: Argonian Behemoth"                                                          }
, { collectible_id = 1111, name = "Bust: Captain Blackheart"                                                         }
, { collectible_id = 1112, name = "Bust: Shadowrend"                                                                 }
, { collectible_id = 1113, name = "Bust: Maw of the Infernal"                                                        }
, { collectible_id = 1114, name = "Bust: Kra'gh the Dreugh King"                                                     }
, { collectible_id = 1115, name = "Bust: Tremorscale"                                                                }
, { collectible_id = 1116, name = "Bust: Sentinel of Rkugamz"                                                        }
, { collectible_id = 1117, name = "Bust: Engine Guardian"                                                            }
, { collectible_id = 1118, name = "Bust: Blood Spawn"                                                                }
, { collectible_id = 1119, name = "Bust: Slimecraw"                                                                  }
, { collectible_id = 1120, name = "Bust: Swarm Mother"                                                               }
, { collectible_id = 1121, name = "Bust: Lord Warden Dusk"                                                           }
, { collectible_id = 1122, name = "Bust: The Mighty Chudan"                                                          }
, { collectible_id = 1123, name = "Bust: Malubeth the Scourger"                                                      }
, { collectible_id = 1124, name = "Bust: Hiath the Battlemaster"                                                     }
, { collectible_id = 1125, name = "Bust: Velidreth, Lady of Lace"                                                    }
, { collectible_id = 1126, name = "Bust: Iceheart"                                                                   }
, { collectible_id = 1127, name = "Bust: Sellistrix the Lamia Queen"                                                 }
, { collectible_id = 1128, name = "Bust: Infernal Guardian"                                                          }
, { collectible_id = 1129, name = "Bust: Molag Kena"                                                                 }
, { collectible_id = 1130, name = "Bust: Nerien'eth"                                                                 }
, { collectible_id = 1131, name = "Bust: Spawn of Mephala"                                                           }
, { collectible_id = 1132, name = "Bust: Stormfist"                                                                  }
, { collectible_id = 1133, name = "Bust: Chokethorn"                                                                 }
, { collectible_id = 1134, name = "Bust: Bogdan the Nightflame"                                                      }
, { collectible_id = 1135, name = "Bust: The Troll King"                                                             }
, { collectible_id = 1136, name = "Bust: Valkyn Skoria"                                                              }
, { collectible_id = 1137, name = "Bust: Ra Kotu"                                                                    }
, { collectible_id = 1138, name = "Bust: Rakkhat, Fang of Lorkhaj"                                                   }
, { collectible_id = 1139, name = "Bust: Possessed Mantikora"                                                        }
, { collectible_id = 1140, name = "Bust: Foundation Stone Atronach"                                                  }
, { collectible_id = 1141, name = "Bust: The Ilambris Twins"                                                         }
, { collectible_id = 1142, name = "Bust: Grothdarr"                                                                  }
, { collectible_id = 1143, name = "Bust: Selene"                                                                     }
, { collectible_id = 1144, name = "Molag Amur Cliff Strider"                               , crate = DWARVEN         }
, { collectible_id = 1145, name = "Dwarven War Horse"                                                                } -- exclusively in "Collector's Edition of ESO: Morrowind"
, { collectible_id = 1147, name = "Milady's Cloud Cat"                     , crowns =   700                          }
, { collectible_id = 1148, name = "Shadowghost Senche-Panther"                             , crate = REAPERS_HARVEST }
, { collectible_id = 1152, name = "Snowy Sabre Cat"                                                                  }
, { collectible_id = 1155, name = "Dwarven Spider"                                                                   } -- Collector's Edition of Morrowind
, { collectible_id = 1157, name = "Snow Leopard Sabre Cat"                                                           }
, { collectible_id = 1159, name = "Dwarven Horse"                                          , crate = DWARVEN         }
, { collectible_id = 1160, name = "Dwarven Senche"                                         , crate = DWARVEN         }
, { collectible_id = 1161, name = "Dwarven Bear"                                           , crate = DWARVEN         }
, { collectible_id = 1162, name = "Dwarven Guar"                                           , crate = DWARVEN         }
, { collectible_id = 1163, name = "Dwarven Camel"                                          , crate = DWARVEN         }
, { collectible_id = 1164, name = "Dwarven Wolf"                                           , crate = DWARVEN         }
, { collectible_id = 1169, name = "Ash Hopper"                                                                       }
, { collectible_id = 1170, name = "Seht's Dovah-Fly"                       , crowns =  1000                          }
, { collectible_id = 1171, name = "Vvardenfell Scale Model"                                                          }
, { collectible_id = 1172, name = "Mastiff Pup B Black"                                                              }
, { collectible_id = 1173, name = "Brassilisk"                                                                       } -- ?
, { collectible_id = 1174, name = "Ebon Dwarven Wolf"                                                                } -- ?
, { collectible_id = 1184, name = "Gorne Striped Wolf"                                     , crate = DWARVEN         }
, { collectible_id = 1185, name = "Dwarven Spider"                                                                   } -- zz unowned. Hrm.
, { collectible_id = 1186, name = "Chroma-Blue Dwarven Spider"             , crowns =  4000                          }
, { collectible_id = 1187, name = "Kagouti Fabricant"                      , crowns =  3000                          }
, { collectible_id = 1188, name = "Pellitine Mustang"                                                                }
, { collectible_id = 1189, name = "Adamant Dwarven Horse"                                  , crate = DWARVEN         }
, { collectible_id = 1190, name = "Adamant Dwarven Senche"                                                           } -- ?
, { collectible_id = 1191, name = "Adamant Dwarven Wolf"                                                             } -- ?
, { collectible_id = 1193, name = "Mastiff Pup A White"                                                              }
, { collectible_id = 1194, name = "Tuxedo Vvardvark"                                       , crate = DWARVEN         }
, { collectible_id = 1214, name = "Karthwolf Shepherd"                     , crowns =  1000                          }
, { collectible_id = 1232, name = "Dwarven Theodolite"                                                               } -- Nchuleftingth reward
, { collectible_id = 1237, name = "Bust: Assembly General"                                                           }
, { collectible_id = 1241, name = "Vvardvark"                              , crowns =   700, crate = PSIJIC_VAULT    }
, { collectible_id = 1242, name = "Saint Delyn Penthouse"                  , crowns =   nil                          , gold =   3000 , house_id = 42 }
, { collectible_id = 1243, name = "Amaya Lake Lodge"                       , crowns =  7000                          , gold =1300000 , house_id = 43 }
, { collectible_id = 1244, name = "Ald Velothi Harbor House"               , crowns =  4000                          , gold = 332000 , house_id = 44 }
, { collectible_id = 1245, name = "Tel Galen"                              , crowns =  8000                          , gold =    nil , house_id = 45 }
, { collectible_id = 1250, name = "Ebon Dwarven Horse"                                                               }
, { collectible_id = 1251, name = "Vitrine Dwarven Horse"                                                            }
, { collectible_id = 1252, name = "Ebon Dwarven Senche"                                    , crate = DWARVEN         }
, { collectible_id = 1253, name = "Vitrine Dwarven Senche"                                                           } --?
, { collectible_id = 1254, name = "Vitrine Dwarven Wolf"                                   , crate = DWARVEN         }
, { collectible_id = 1258, name = "Bust: Domihaus"                                                                   }
, { collectible_id = 1259, name = "Bust: Earthgore Amalgam"                                                          }
, { collectible_id = 1265, name = "Trophy: Argonian Behemoth"                                                        }
, { collectible_id = 1266, name = "Trophy: Captain Blackheart"                                                       }
, { collectible_id = 1267, name = "Trophy: Shadowrend"                                                               }
, { collectible_id = 1268, name = "Trophy: Maw of the Infernal"                                                      }
, { collectible_id = 1269, name = "Trophy: Kra'gh the Dreugh King"                                                   }
, { collectible_id = 1270, name = "Trophy: Tremorscale"                                                              }
, { collectible_id = 1271, name = "Trophy: Sentinel of Rkugamz"                                                      }
, { collectible_id = 1272, name = "Trophy: Engine Guardian"                                                          }
, { collectible_id = 1273, name = "Trophy: Blood Spawn"                                                              }
, { collectible_id = 1274, name = "Trophy: Slimecraw"                                                                }
, { collectible_id = 1275, name = "Trophy: Swarm Mother"                                                             }
, { collectible_id = 1276, name = "Trophy: Lord Warden Dusk"                                                         }
, { collectible_id = 1277, name = "Trophy: The Mighty Chudan"                                                        }
, { collectible_id = 1278, name = "Trophy: Malubeth the Scourger"                                                    }
, { collectible_id = 1279, name = "Trophy: Hiath the Battlemaster"                                                   }
, { collectible_id = 1280, name = "Trophy: Velidreth, Lady of Lace"                                                  }
, { collectible_id = 1281, name = "Trophy: Iceheart"                                                                 }
, { collectible_id = 1282, name = "Trophy: Sellistrix"                                                               }
, { collectible_id = 1283, name = "Trophy: Infernal Guardian"                                                        }
, { collectible_id = 1284, name = "Trophy: Molag Kena"                                                               }
, { collectible_id = 1285, name = "Trophy: Nerien'eth"                                                               }
, { collectible_id = 1286, name = "Trophy: Spawn of Mephala"                                                         }
, { collectible_id = 1287, name = "Trophy: Stormfist"                                                                }
, { collectible_id = 1288, name = "Trophy: Chokethorn"                                                               }
, { collectible_id = 1289, name = "Trophy: Bogdan the Nightflame"                                                    }
, { collectible_id = 1290, name = "Trophy: The Troll King"                                                           }
, { collectible_id = 1291, name = "Trophy: Valkyn Skoria"                                                            }
, { collectible_id = 1292, name = "Trophy: Ra Kotu"                                                                  }
, { collectible_id = 1293, name = "Trophy: Rakkhat, Fang of Lorkhaj"                                                 }
, { collectible_id = 1294, name = "Trophy: Possessed Mantikora"                                                      }
, { collectible_id = 1295, name = "Trophy: Stone Atronach"                                                           }
, { collectible_id = 1296, name = "Trophy: The Ilambris Twins"                                                       }
, { collectible_id = 1297, name = "Trophy: Grothdarr"                                                                }
, { collectible_id = 1298, name = "Trophy: Selene"                                                                   }
, { collectible_id = 1299, name = "Trophy: Assembly General"                                                         }
, { collectible_id = 1300, name = "Trophy: Domihaus"                                                                 }
, { collectible_id = 1301, name = "Trophy: Earthgore Amalgam"                                                        }
, { collectible_id = 1303, name = "Nightmare Senche"                                                                 }
, { collectible_id = 1309, name = "Linchal Grand Manor"                    , crowns = 14000                          , gold =     nil, house_id = 46 }
, { collectible_id = 1310, name = "Exorcised Coven Cottage"                , crowns =  3500                          , gold =     nil, house_id = 49 }
, { collectible_id = 1311, name = "Hakkvild's High Hall"                   , crowns = 12000                          , gold = 3800000, house_id = 48 }
, { collectible_id = 1312, name = "Coldharbour Surreal Estate"             , crowns =  5600                          , gold = 1000000, house_id = 47 }
, { collectible_id = 1332, name = "Karthwolf Charger"                      , crowns =  2200                          }
, { collectible_id = 1335, name = "Skeletal Pack Wolf"                                                               } -- ?
, { collectible_id = 1336, name = "Jackdaw Daedrat"                        , crowns =   700                          }
, { collectible_id = 1337, name = "Skeletal Senche-Leopard"                                                          } -- ?
, { collectible_id = 1345, name = "Haunted House Cat"                                                                } -- daily reward
, { collectible_id = 1356, name = "Shadowghost Horse"                      , crowns =  2000                          }
, { collectible_id = 1359, name = "Witch Knight Charger"                   , crowns =  2500                          }
, { collectible_id = 1360, name = "Frost Draugr Skeletal Horse"                                                      }
, { collectible_id = 1361, name = "Nix-Ox War-Steed"                                                                 } -- promo for Morrowind owners
, { collectible_id = 1362, name = "Plague Husk Skeletal Senche"                                                      }
, { collectible_id = 1371, name = "Dire Pony"                              , crowns =  1200                          }
, { collectible_id = 1330, name = "Cinder Wolf"                                            , crate = REAPERS_HARVEST }
, { collectible_id = 1372, name = "Plague Husk Horse"                                      , crate = REAPERS_HARVEST }
, { collectible_id = 1373, name = "Shadowghost Senche"                     , crowns =  2000                          }
, { collectible_id = 1374, name = "Shadowghost Pony"                       , crowns =   700                          }
, { collectible_id = 1375, name = "Mastiff Pup C Gray"                                                               }
, { collectible_id = 1376, name = "Frost Draugr Senche"                                    , crate = REAPERS_HARVEST }
, { collectible_id = 1377, name = "Cinder Skeletal Senche"                                                           }
, { collectible_id = 1378, name = "Reanimated Cat"                                                                   }
, { collectible_id = 1379, name = "Brassilisk Silver"                                                                }
, { collectible_id = 1380, name = "Clockwork Skeevaton"                    , crowns =   700                          } -- also part of Clockwork City Collector's Bundle
, { collectible_id = 1381, name = "Shadowghost Wolf"                       , crowns =  2000                          }
, { collectible_id = 1387, name = "Shadowghost Pack Wolf"                                  , crate = REAPERS_HARVEST }
, { collectible_id = 1392, name = "Flame Atronach Camel"                                   , crate = FLAME_ATRONACH  }
, { collectible_id = 1393, name = "Flame Atronach Guar"                                    , crate = FLAME_ATRONACH  }
, { collectible_id = 1394, name = "Flame Atronach Bear"                                    , crate = FLAME_ATRONACH  }
, { collectible_id = 1395, name = "Shadowghost Guar"                                                                 }
, { collectible_id = 1396, name = "Shadowghost Guar"                                       , crate = REAPERS_HARVEST }
, { collectible_id = 1409, name = "Flame Atronach Horse"                                   , crate = FLAME_ATRONACH  }
, { collectible_id = 1410, name = "Flame Atronach Senche"                                  , crate = FLAME_ATRONACH  }
, { collectible_id = 1411, name = "Flame Atronach Wolf"                                    , crate = FLAME_ATRONACH  }
, { collectible_id = 1412, name = "Flame Atronach Bear Cub"                                                          } -- ?
, { collectible_id = 1413, name = "Frostbane Sabre Cat"                                                              }
, { collectible_id = 1414, name = "Shadow Atronach Senche"                                 , crate = FLAME_ATRONACH  }
, { collectible_id = 1415, name = "Flame Atronach Senche-Jaguar"                                                     } -- ?
, { collectible_id = 1416, name = "Flame Atronach Pack Wolf"                                                         } -- ?
, { collectible_id = 1417, name = "Flame Atronach Pocket Horse"                                                      } -- ?
, { collectible_id = 1418, name = "Cold Flame Atronach Wolf"                               , crate = FLAME_ATRONACH  }
, { collectible_id = 1427, name = "Skyfire Guar"                           , crowns =  2500                          }
, { collectible_id = 1431, name = "Prodigious Brass Mudcrab"                               , crate = FLAME_ATRONACH  }
, { collectible_id = 1432, name = "Helkarn Wolf"                                                                     } -- ?
, { collectible_id = 1437, name = "Winter Garland Dapple Gray"             , crowns =  2500                          }
, { collectible_id = 1440, name = "Ebony Brassilisk"                                       , crate = FLAME_ATRONACH  }
, { collectible_id = 1441, name = "Flame Atronach Pony Guar"                                                         } -- ?
, { collectible_id = 1444, name = "Night Frost Atronach Steed"                             , crate = FLAME_ATRONACH  }
, { collectible_id = 1445, name = "Pariah's Pinnacle"                      , crowns = 13000                          , gold =     nil, house_id = 54 }
, { collectible_id = 1446, name = "The Orbservatory Prior"                 , crowns = 12000                          , gold =     nil, house_id = 55 }
, { collectible_id = 1447, name = "Spotted Snow Senche-Leopard"                                                      } -- crowns, unknown
, { collectible_id = 1448, name = "White-Gold Imperial Pony"               , crowns =  1000                          }
, { collectible_id = 1456, name = "Frostbane Guar"                                                                   }
, { collectible_id = 1457, name = "Frostbane Wolf"                                                                   }
, { collectible_id = 1472, name = "Mages Guild Sentry Cat"                                 , crate = FLAME_ATRONACH  }
, { collectible_id = 1473, name = "Scorpion Fabricant"                                     , crate = FLAME_ATRONACH  }
, { collectible_id = 1474, name = "Lustrous Nix-Ox Fabricant Steed"        , crowns =  3500                          }
, { collectible_id = 1484, name = "White-Gold Imperial Courser"            , crowns =  3500                          }
, { collectible_id = 1485, name = "Psijic Brassilisk"                                                                } -- PS4
, { collectible_id = 1486, name = "Foxbat Brassilisk"                                                                } -- PS4 preorder Morrowind
, { collectible_id = 1487, name = "Steam-Driven Brassilisk"                                                          } -- free
, { collectible_id = 4659, name = "Scintillant Dovah-Fly"                                                            } -- free with Clockwork City
, { collectible_id = 4664, name = "Revolving Celestiodrome"                                                          }
, { collectible_id = 4665, name = "Trophy: Saint Olms the Just"                                                      }
, { collectible_id = 4666, name = "Bust: Saint Olms the Just"                                                        }
, { collectible_id = 4667, name = "Nix-Ox Fabricant Steed"                 , crowns = 3500                           }
, { collectible_id = 4668, name = "Firepot Spider"                                                                   }
, { collectible_id = 4669, name = "Firepot Spider Melee"                                                             }
, { collectible_id = 4671, name = "Frostbane Bear"                                                                   } -- ?
, { collectible_id = 4672, name = "Frostbane Camel"                                                                  }
, { collectible_id = 4673, name = "Storage Coffer, Fortified"                                                        } -- Free at level 18
, { collectible_id = 4674, name = "Storage Chest, Fortified"               , crowns =  2000                          , vouchers = 200, tel_var = 200000 }
, { collectible_id = 4675, name = "Storage Coffer, Oaken"                  , crowns =  1000                          , vouchers = 100, tel_var = 100000 }
, { collectible_id = 4676, name = "Storage Coffer, Secure"                 , crowns =  1000                          , vouchers = 100, tel_var = 100000 }
, { collectible_id = 4677, name = "Storage Coffer, Sturdy"                 , crowns =  1000                          , vouchers = 100, tel_var = 100000 }
, { collectible_id = 4678, name = "Storage Chest, Oaken"                   , crowns =  2000                          , vouchers = 200, tel_var = 200000 }
, { collectible_id = 4679, name = "Storage Chest, Secure"                  , crowns =  2000                          , vouchers = 200, tel_var = 200000 }
, { collectible_id = 4680, name = "Storage Chest, Sturdy"                  , crowns =  2000                          , vouchers = 200, tel_var = 200000 }
, { collectible_id = 4709, name = "Fang Lair Courser"                      , crowns =  3000                          }
, { collectible_id = 4710, name = "Masqued \"Unicorn\" Steed"                                                        }
, { collectible_id = 4712, name = "True Ghost Horse"                                                                 }
, { collectible_id = 4713, name = "Manelord Nightmare Senche"                                                        }
, { collectible_id = 4714, name = "Frostbane Horse"                                                                  }
, { collectible_id = 4720, name = "Dragonfire Wolf"                                                                  }
, { collectible_id = 4721, name = "Galvanic Storm Steed"                                                             }
, { collectible_id = 4722, name = "Snow-Blanket Sorrel Horse"                                                        }
, { collectible_id = 4723, name = "Tattooed Shorn Camel"                                   , crate = HOLLOWJACK      }
, { collectible_id = 4724, name = "Bal Foyen Circus Guar"                                                            }
, { collectible_id = 4726, name = "Small Bone Dragon Construct"                                                      } -- Dragon Bones Collector's Bundle
, { collectible_id = 4727, name = "Unholy Glow Bone Dragon"                                                          } -- ?
, { collectible_id = 4728, name = "Madcap Jester Monkey"                                                             } -- ?
, { collectible_id = 4729, name = "Karth Winter Hound"                                                               } -- ?
, { collectible_id = 4731, name = "Flameback Boar"                                         , crate = SCALECALLER     }
, { collectible_id = 4732, name = "Mournhold Packrat"                                                                } -- ?
, { collectible_id = 4733, name = "Wrothgar Buck Goat"                     , crowns =   700                          }
, { collectible_id = 4734, name = "Big-Eared Ginger Mouser"                                , crate = SCALECALLER     }
, { collectible_id = 4735, name = "Karth Winter Pup"                                                                 } -- ?
, { collectible_id = 4736, name = "Nightmare Senche Cub"                                                             } -- ?
, { collectible_id = 4737, name = "Mage's Sentry Kitten"                                                             } -- ?
, { collectible_id = 4739, name = "Helkarn Wolf Pup"                                                                 } -- ?
, { collectible_id = 4740, name = "Bristleneck War Boar"                                                             } -- ?
, { collectible_id = 4741, name = "Magma Scamp"                                            , crate = SCALECALLER     }
, { collectible_id = 4744, name = "Frostbane Pony Guar"                                                              } -- ?
, { collectible_id = 4745, name = "Frostbane Sabre Cat"                                                              }
, { collectible_id = 4746, name = "Frostbane Bear"                                                                   }
, { collectible_id = 4747, name = "Frostbane Wolf"                                                                   } -- ?
, { collectible_id = 4748, name = "Frostbane Pony"                                                                   } -- ?
, { collectible_id = 4749, name = "Ashen Fang Lair Courser"                                                          } -- ?
, { collectible_id = 4751, name = "Trophy: Scalecaller"                                                              }
, { collectible_id = 4752, name = "Trophy: Thurvokun"                                                                }
, { collectible_id = 4753, name = "Bust: Scalecaller"                                                                }
, { collectible_id = 4754, name = "Bust: Thurvokun"                                                                  }
, { collectible_id = 4794, name = "The Erstwhile Sanctuary"                , crowns = 13000                          , gold =     nil, house_id = 56 }
, { collectible_id = 4795, name = "Princely Dawnlight Palace"              , crowns = 14000                          , gold =     nil, house_id = 57 }
, { collectible_id = 4796, name = "Shadow-Rider Senche"                                                              }
, { collectible_id = 4993, name = "Tythis Andromo, the Banker"                                                       }
, { collectible_id = 4996, name = "Big-Eared Ginger Kitten"                                                          } -- Karnwasten reward
, { collectible_id = 5056, name = "Psijic Horse Exemplar"                                  , crate = PSIJIC_VAULT    }
, { collectible_id = 5057, name = "Psijic Camel Exemplar"                                  , crate = PSIJIC_VAULT    }
, { collectible_id = 5058, name = "Psijic Wolf Exemplar"                                   , crate = PSIJIC_VAULT    }
, { collectible_id = 5059, name = "Psijic Guar Exemplar"                                   , crate = PSIJIC_VAULT    }
, { collectible_id = 5060, name = "Psijic Bear Exemplar"                                   , crate = PSIJIC_VAULT    }
, { collectible_id = 5062, name = "Psijic Senche Exemplar"                                 , crate = PSIJIC_VAULT    }
, { collectible_id = 5063, name = "Psijic Spectral Steed"                                  , crate = PSIJIC_VAULT    }
, { collectible_id = 5064, name = "Phantom Ice Wolf"                                       , crate = PSIJIC_VAULT    }
, { collectible_id = 5065, name = "Green-Graht Ghost Cat"                                  , crate = PSIJIC_VAULT    }
, { collectible_id = 5066, name = "Auroran Warhorse"                       , crowns =  3000                          }
, { collectible_id = 5067, name = "Dawnwood Indrik"                                                                  } -- ?
, { collectible_id = 5068, name = "Luminous Indrik"                                                                  } -- ?
, { collectible_id = 5071, name = "Bloodshadow Wraith Steed"                                                         } -- included with "Summerset Collector's Edition"
, { collectible_id = 5072, name = "Badger Bear"                                                                      } -- ?
, { collectible_id = 5073, name = "Senche-Cougar"                          , crowns =  2500                          }
, { collectible_id = 5075, name = "Painted Wolf"                                                                     }
, { collectible_id = 5076, name = "Noweyr Steed"                                                                     }
, { collectible_id = 5077, name = "Senche of Scarlet Regret"                               , crate = OUROBOROS       }
, { collectible_id = 5078, name = "Ja'khajiit Raz"                                                                   }
, { collectible_id = 5079, name = "Firepet Spider"                                                                   }
, { collectible_id = 5080, name = "Alinor Ringtail"                                                                  }
, { collectible_id = 5081, name = "Great Daenian Hound"                                                              }
, { collectible_id = 5082, name = "Larval Yaghra"                                                                    } -- ?
, { collectible_id = 5083, name = "Prong-Eared Grimalkin"                  , crowns =  1000                          }
, { collectible_id = 5084, name = "Coral Mudcrab"                          , crowns =   700                          }
, { collectible_id = 5085, name = "Springtide Indrik"                                                                }
, { collectible_id = 5086, name = "Longhair Welwa"                                         , crate = PSIJIC_VAULT    }
, { collectible_id = 5087, name = "Shimmering Indrik"                                                                }
, { collectible_id = 5088, name = "Skein Shalk"                                                                      }
, { collectible_id = 5089, name = "Skein Spider"                                                                     }
, { collectible_id = 5090, name = "Skein Scorpion"                                                                   }
, { collectible_id = 5091, name = "Skein Wasp"                                                                       }
, { collectible_id = 5092, name = "Fawn Echalette"                                                                   }
, { collectible_id = 5093, name = "Masked Bear Cub"                                                                  }
, { collectible_id = 5094, name = "Psijic Mascot Pony"                                                               } -- Summerfall reward
, { collectible_id = 5095, name = "Psijic Mascot Wolf Pup"                                                           }
, { collectible_id = 5096, name = "Psijic Mascot Guar Calf"                                                          } -- Daily Rewards
, { collectible_id = 5097, name = "Psijic Mascot Bear Cub"                                                           }
, { collectible_id = 5098, name = "Psijic Mascot Senche Cub"                                                         }
, { collectible_id = 5099, name = "Pocket Salamander"                                                                } -- preorder Summerset
, { collectible_id = 5101, name = "Noweyr Pony"                                                                      }
, { collectible_id = 5102, name = "Senche Cub of Scarlet Regret"                                                     }
, { collectible_id = 5103, name = "Shiny Gold Tiger Cub"                                                             }
, { collectible_id = 5105, name = "Fledgling Gryphon"                                                                } -- Summerset
, { collectible_id = 5167, name = "Golden Gryphon Garret"                  , crowns =   nil                          , gold =    3000, house_id = 58 }
, { collectible_id = 5168, name = "Alinor Crest Townhouse"                 , crowns =  6000                          , gold = 1025000, house_id = 59 }
, { collectible_id = 5169, name = "Colossal Aldmeri Grotto"                , crowns = 15000                          , gold =     nil, house_id = 60 }
, { collectible_id = 5172, name = "Atmoran Snow Bear Cub"                                                            }
, { collectible_id = 5173, name = "Atmoran Snow Bear"                                      , crate = HOLLOWJACK      }
, { collectible_id = 5176, name = "Daemon Cockerel"                                                                  }
, { collectible_id = 5179, name = "Ebon Steel Dwarven Spider"              , crowns =  3600                          } -- ESO Plus exclusive
, { collectible_id = 5180, name = "Solar Arc Dwarven Spider"                                                         }
, { collectible_id = 5188, name = "Teal-Faced Fellrunner"                                                            }
, { collectible_id = 5190, name = "Silver Daenian Werewolf Tracker"                                                  }
, { collectible_id = 5196, name = "Azure Fledgling Gryphon"                                                          } -- Gryphon Plush Toy reward
, { collectible_id = 5213, name = "Packlord Nightmare Wolf"                                                          }
, { collectible_id = 5214, name = "Nightmare Wolf Pup"                                                               }
, { collectible_id = 5219, name = "Lava Line Salamander"                                                             }
, { collectible_id = 5222, name = "Crested Reef Viper"                                                               }
, { collectible_id = 5223, name = "Noble Riverhold Senche-Lion Cub"                                                  }
, { collectible_id = 5224, name = "Noble Riverhold Senche-Lion"                                                      }
, { collectible_id = 5225, name = "Death Mask Sabre Cat"                                                             }
, { collectible_id = 5226, name = "Floral Tattoo Shorn Camel"                                                        }
, { collectible_id = 5236, name = "Silver Dawn Argent Charger"                                                       }
, { collectible_id = 5244, name = "Goldenback Spider Lackey"                                                         }
, { collectible_id = 5245, name = "Hollowjack Rider Horse"                                 , crate = HOLLOWJACK      }
, { collectible_id = 5246, name = "Hollowjack Rider Camel"                                 , crate = HOLLOWJACK      }
, { collectible_id = 5247, name = "Hollowjack Rider Wolf"                                  , crate = HOLLOWJACK      }
, { collectible_id = 5248, name = "Hollowjack Rider Guar"                                  , crate = HOLLOWJACK      }
, { collectible_id = 5249, name = "Hollowjack Rider Bear"                                  , crate = HOLLOWJACK      }
, { collectible_id = 5250, name = "Hollowjack Rider Senche"                                , crate = HOLLOWJACK      }
, { collectible_id = 5251, name = "Hollowjack Wraith-Lantern Steed"                                                  }
, { collectible_id = 5252, name = "Hollowjack Flame-Skull Senche"                                                    }
, { collectible_id = 5253, name = "Hollowjack Daedra-Skull Wolf"                                                     }
, { collectible_id = 5458, name = "Trophy: Z'Maja"                                                                   }
, { collectible_id = 5459, name = "Bust: Z'Maja"                                                                     }
, { collectible_id = 5460, name = "Fan of False-Face"                                                                }
, { collectible_id = 5461, name = "Hunter's Glade"                         , crowns =  8000                          , gold =     nil, house_id = 61 }
, { collectible_id = 5462, name = "Grand Psijic Villa"                     , crowns =   nil                          , gold =     nil, house_id = 62 }
, { collectible_id = 5470, name = "Auroran Zenith Warhorse"                                                          } -- ?
, { collectible_id = 5471, name = "Auroran Twilight Warhorse"                                                        } -- ?
, { collectible_id = 5539, name = "Augur of the Obscure"                                                             }
, { collectible_id = 5547, name = "Witches Party Ghost Netch"                                                        }
, { collectible_id = 5548, name = "Pale-Plume Fledgling Gryphon"                                                     } -- ?
, { collectible_id = 5549, name = "Onyx Indrik"                                                                      } -- ?
, { collectible_id = 5550, name = "Pure-Snow Indrik"                                                                 } -- ?
, { collectible_id = 5551, name = "Black Fredas Soot Stallion"                                                       }
, { collectible_id = 5552, name = "Rahd-m'Athra"                                                                     } -- ?
, { collectible_id = 5553, name = "Wolf-Lizard Steed"                                                                } -- ?
, { collectible_id = 5554, name = "Senche-Lizard Steed"                                                              } -- ?
, { collectible_id = 5555, name = "Guar-Lizard Steed"                                                                } -- ?
, { collectible_id = 5556, name = "Camel-Lizard Steed"                                                               } -- ?
, { collectible_id = 5557, name = "Bear-Lizard Steed"                                                                } -- ?
, { collectible_id = 5558, name = "Horse-Lizard Steed"                                                               } -- ?
, { collectible_id = 5559, name = "Sabre Cat Frost Atronach"                                                         } -- ?
, { collectible_id = 5560, name = "Shellback Warhorse"                                                               } -- ?
, { collectible_id = 5561, name = "Glowgill Guar"                                                                    } -- ?
, { collectible_id = 5562, name = "Ice Nixad"                                                                        }
, { collectible_id = 5563, name = "Cantaloupe Swamp Jelly"                 , crowns =  1000                          }
, { collectible_id = 5564, name = "Mint Swamp Jelly"                                                                 }
, { collectible_id = 5565, name = "Plum Swamp Jelly"                                                                 }
, { collectible_id = 5600, name = "Hollowjack Netch"                                                                 }
, { collectible_id = 5601, name = "Snowcap Fledgling Gryphon"                                                        }
, { collectible_id = 5602, name = "Trophy: Vykosa the Ascendant"                                                     }
, { collectible_id = 5603, name = "Trophy: Balorgh"                                                                  }
, { collectible_id = 5604, name = "Bust: Vykosa the Ascendant"                                                       }
, { collectible_id = 5605, name = "Bust: Balorgh"                                                                    }
, { collectible_id = 5619, name = "Daemon Chicken"                                                                   }
, { collectible_id = 5620, name = "Riverwood White Hen"                                                              }
, { collectible_id = 5635, name = "Psijic Camel v2"                                                                  }
, { collectible_id = 5636, name = "Psijic Guar v2"                                                                   }
, { collectible_id = 5637, name = "Psijic Bear v2"                                                                   }
, { collectible_id = 5638, name = "Psijic Wolf v2"                                                                   }
, { collectible_id = 5639, name = "Psijic Senche v2"                                                                 }
, { collectible_id = 5640, name = "Psijic Escort Charger"                                                            } -- Summerfall reward
, { collectible_id = 5641, name = "Corrupted Indrik"                                                                 }
, { collectible_id = 5642, name = "Wild Chicken Color"                                                               }
, { collectible_id = 5643, name = "Wild Rooster Color"                                                               }
, { collectible_id = 5654, name = "Rooster White"                                                                    }
, { collectible_id = 5656, name = "Swamp Jelly"                                                                      } -- Cyrydilic Collections daily reward
, { collectible_id = 5657, name = "Kaleidotropic Dragon Frog"                                                        }
, { collectible_id = 5658, name = "Butterscotch Dragon Frog"                                                         }
, { collectible_id = 5659, name = "Flame Skin Salamander"                                                            }
, { collectible_id = 5660, name = "Toxin Skin Salamander"                                                            }
, { collectible_id = 5661, name = "Shock Skin Salamander"                                                            }
, { collectible_id = 5662, name = "Prong-Eared Odd-Eyed Cat"                                                         }
, { collectible_id = 5663, name = "Prong-Eared Forge Mouser"                                                         }
, { collectible_id = 5697, name = "Scorching Horse-Lizard"                                                           } -- ?
, { collectible_id = 5698, name = "Infernium Dwarven Spider"                                                         } -- ?
, { collectible_id = 5699, name = "Infernium Dwarven Spiderling"                                                     }
, { collectible_id = 5705, name = "Chilling Senche-Lizard"                                                           } -- ?
, { collectible_id = 5706, name = "Venomous Wolf-Lizard"                                                             } -- ?
, { collectible_id = 5707, name = "Rimmen Ringtailed Wolf"                                                           } -- ?
, { collectible_id = 5709, name = "Sapiarchic Senche-Serval"                                                         } -- ?
, { collectible_id = 5710, name = "Nascent Indrik"                                                                   }
, { collectible_id = 5712, name = "Slateback Haj Mota"                                                               }
, { collectible_id = 5713, name = "Verdigris Haj Mota"                                                               } -- Free with Murkmire
, { collectible_id = 5714, name = "Bear-Lizard Cub"                                                                  }
, { collectible_id = 5715, name = "Pony-Lizard"                                                                      }
, { collectible_id = 5716, name = "Senche-Lizard Cub"                                                                }
, { collectible_id = 5717, name = "Wolf-Lizard Pup"                                                                  }
, { collectible_id = 5718, name = "Guar-Lizard Calf"                                                                 }
, { collectible_id = 5719, name = "Badger Ruff Echalette"                                                            }
, { collectible_id = 5720, name = "Monarch Butterfly"                                                                }
, { collectible_id = 5723, name = "Brimstone Nixad"                                                                  }
, { collectible_id = 5756, name = "Enchanted Snow Globe Home"              , crowns =  4200                          , gold =     nil, house_id = 63 }
, { collectible_id = 5757, name = "Lakemire Xanmeer Manor"                 , crowns =   nil                          , gold =     nil, house_id = 64 }
, { collectible_id = 5930, name = "Replica of the Xinchei-Konu"                                                      }
}
