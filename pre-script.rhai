// we can see existing variables.
// note that template and Rhai variables are separate!
let chip = variable::get("chip").to_lower();
let version_type = variable::get("version");

let ram_address;
let ccram_address = "0x10000000";
let itcm_address = "0x00000000";
let dtcm_address = 0x20000000;
let flash_address = "0x08000000";
let flash_lit = chip[10];
let flash = switch flash_lit.to_upper() {
    '4' => 16,
    '6' => 32,
    '8' => 64,
    'B' => 128,
    'Z' => 192,
    'C' => 256,
    'D' => 384,
    'E' => 512,
    'F' => 768,
    'G' => 1024,
    'H' => 1536,
    'I' => 2048,
    _ => throw "Unknown FLASH size",
};

let target;
let hal;
let hal_version;
let chipserie;
let chipfamily;
let ccram = 0;
let dtcm = 0;
let itcm = 0;
let backupram = 0;
let ram;
if chip.starts_with("stm32f1") {
    target = "thumbv7m-none-eabi";
    hal = "stm32f1xx-hal";
    hal_version = "0.10.0";
    chipfamily = "stm32f1";
    chipserie = chip.sub_string(0,9);
    switch chipserie {
        "stm32f100" => {
            ram = switch flash {
                16 | 32 => 4,
                64 | 128 => 8,
                256 => 24,
                384 | 512 => 32,
            };
        }
        "stm32f101" | "stm32f102" => {
            ram = switch flash {
                16 => 4,
                32 => 6,
                64 => 10,
                128 => 16,
                256 => 32,
                384 | 512 => 48,
                768 | 1024 => 80,
            };
        }
        "stm32f103" => {
            ram = switch flash {
                16 => 6,
                32 => 10,
                64 | 128 => 20,
                256 => 48,
                384 | 512 => 64,
                768 | 1024 => 96,
            };
        }
        "stm32f105" | "stm32f107" => {
            ram = 64;
        }
    }
    ram_address = 0x20000000;
} else if chip.starts_with("stm32f3") {
    target = "thumbv7em-none-eabihf";
    hal = "stm32f3xx-hal";
    hal_version = "0.9.2";
    chipfamily = "stm32f3";
    chipserie = chip.sub_string(0,9);
    switch chipserie {
        "stm32f301" | "stm32f318" => {
            ram = 16;
        }
        "stm32f302" => {
            ram = switch flash {
                32 | 64 => 16,
                128 => 32,
                256 => 40,
                384 | 512 => 64,
            };
        }
        "stm32f303" => {
            switch flash {
                32 | 64 => {
                    ram = 12;
                    ccram = 4;
                },
                128 => {
                    ram = 32;
                    ccram = 8;
                }
                256 => {
                    ram = 40;
                    ccram = 8;
                }
                384 | 512 => {
                    ram = 64;
                    ccram = 16;
                }
            }
        }
        "stm32f328" | "stm32f334" => {
            ram = 12;
            ccram = 4;
        },
        "stm32f358" => {
            ram = 40;
            ccram = 8;
        },
        "stm32f373" => {
            ram = switch flash {
                64 => 16,
                128 => 24,
                256 => 32,
            };
        }
        "stm32f378" => {
            ram = 32;
        },
        "stm32f398" => {
            ram = 64;
            ccram = 16;
        },
        _ => throw "Unknown RAM size",
    }
    ram_address = 0x20000000;
} else if chip.starts_with("stm32f4") {
    target = "thumbv7em-none-eabihf";
    hal = "stm32f4xx-hal";
    hal_version = "0.14.0";
    chipfamily = "stm32f4";
    chipserie = chip.sub_string(0,9);
    switch chipserie {
        "stm32f401" => {
            ram = switch flash {
                128 | 256 => 64,
                384 | 512 => 96,
            };
        }
        "stm32f405" | "stm32f407" | "stm32f415" | "stm32f417" => {
            ram = 112+16;
            ccram = 64;
            backupram = 4;
        }
        "stm32f410" => {
            ram = 32;
        }
        "stm32f411" => {
            ram = 128;
        }
        "stm32f412" => {
            ram = 256;
        }
        "stm32f427" | "stm32f429" | "stm32f437" | "stm32f439" => {
            ram = 112+16+64;
            ccram = 64;
            backupram = 4;
        }
        "stm32f413" | "stm32f423" => {
            ram = 256+64;
        }
        "stm32f446" => {
            ram = 112+16;
            backupram = 4;
        }
        "stm32f469" | "stm32f479" => {
            ram = 160+32+128;
            ccram = 64;
            backupram = 4;
        }
        _ => throw "Unknown RAM size",
    }
    ram_address = 0x20000000;
} else if chip.starts_with("stm32f7") {
    target = "thumbv7em-none-eabihf";
    hal = "stm32f7xx-hal";
    hal_version = "0.7.0";
    chipfamily = "stm32f7";
    chipserie = chip.sub_string(0,9);
    switch chipserie {
        "stm32f722" | "stm32f723" | "stm32f730" | "stm32f732" | "stm32f733" => {
            ram = 176+16;
            dtcm = 64;
        }
        "stm32f745" | "stm32f746" | "stm32f750" | "stm32f756" => {
            ram = 240+16;
            dtcm = 64;
        }
        "stm32f765" | "stm32f767" | "stm32f768" | "stm32f769" | "stm32f777" | "stm32f778" | "stm32f779" => {
            ram = 368+16;
            dtcm = 128;
        }
    }
    ram_address += dtcm*1024;
    itcm = 16;
    backupram = 4;
/*} else if chip.starts_with("stm32h7") {
    target = "thumbv7em-none-eabihf";
    hal = "stm32h7xx-hal";
    hal_version = "0.7.0";
    chipfamily = "stm32h7";
    chipserie = chip.sub_string(0,9);
    switch chipserie {
        "stm32h723" | "stm32h725" | "stm32h730" | "stm32h733" | "stm32h735" => {
            axi = 128;
            itcm_axi = 196;
            ram = 16+16;
            ram4 = 16;
            dtcm = 128;
        }
    }
    itcm = 64;
    backupram = 4;
    itcm_axi_address = 0x24020000; // 0x00010000
    axi_address = 0x24000000;
    ram_address = 0x30000000;
    ram4_address = 0x38000000;
    backup_address = 0x38800000;
    */
} else if chip.starts_with("stm32g0") {
    target = "thumbv6m-none-eabi";
    hal = "stm32g0xx-hal";
    hal_version = "0.2.0";
    chipfamily = "stm32g0";
    chipserie = chip.sub_string(0,9);
    switch chipserie {
        "stm32g030" | "stm32g031" | "stm32g041" => {
            ram = 8;
        }
        "stm32g050" | "stm32g051" | "stm32g061" => {
            ram = 16; // 18
        }
        "stm32g070" | "stm32g071" | "stm32g081" => {
            ram = 32; // 36
        }
        "stm32g0b0" | "stm32g0b1" | "stm32g0c1"=> {
            ram = 128; // 144
        }
        _ => throw "Unknown RAM size",
    }
    ram_address = 0x20000000;
} else if chip.starts_with("stm32c0") {
    target = "thumbv6m-none-eabi";
    hal = "stm32c0xx-hal";
    version_type = "git"; // not released yet
    hal_version = "0.0.0";
    chipfamily = "stm32c0";
    chipserie = chip.sub_string(0,9);
    switch chipserie {
        "stm32c011" => {
            ram = 6;
        }
        "stm32c031" => {
            ram = 12;
        }
        _ => throw "Unknown RAM size",
    }
    ram_address = 0x20000000;
} else if chip.starts_with("stm32l4") {
    target = "thumbv7em-none-eabihf";
    hal = "stm32l4xx-hal";
    hal_version = "0.7.1";
    chipfamily = "stm32l4";
    chipserie = chip.sub_string(0,9);
    switch chipserie {
        "stm32l412" | "stm32l422" => {
            ram = 32+8;
        }
        "stm32l431" | "stm32l432" | "stm32l433" | "stm32l442" | "stm32l443" => {
            ram = 48+16;
        }
        "stm32l451" | "stm32l452" | "stm32l462"  => {
            ram = 160;
        }
        "stm32l471" | "stm32l475" | "stm32l476" | "stm32l486"  => {
            ram = 128;
        }
        "stm32l496" | "stm32l4a6" => {
            ram = 256+64;
        }
        _ => throw "Unknown RAM size",
    }
    ram_address = 0x20000000;
} else {
    throw "Unknown chip";
};
let hal_ = hal;

let probe_rs_chip = chip.sub_string(0,12).to_upper() + "x";

hal_.replace("-", "_");
debug(`Microcontroller family: ${chipserie}`);

let memory_blocks = `  FLASH (rx) : ORIGIN = ${flash_address}, LENGTH = ${flash}K`;
if ccram > 0 {
    memory_blocks += "\n";
    memory_blocks += `  CCMRAM (rwx) : ORIGIN = ${ccram_address}, LENGTH = {ccram}K`
};
memory_blocks += "\n";
memory_blocks += `  RAM (rwx) : ORIGIN = 0x${ram_address.to_hex()}, LENGTH = ${ram}K`;

if itcm > 0 {
    memory_blocks += "\n";
    memory_blocks += `  ITCM (rwx) : ORIGIN = ${itcm_address}, LENGTH = ${itcm}K /* Instruction Tighly Coupled Memory */`;
}
if dtcm > 0 {
    memory_blocks += "\n";
    memory_blocks += `  DTCM (rwx) : ORIGIN = 0x${dtcm_address.to_hex()}, LENGTH = ${dtcm}K /* Data Tighly Coupled Memory */`;
}

debug(`Linker memory blocks:
${memory_blocks}`);

let hal_dependency = `[dependencies.${hal}]`;
switch version_type {
    "last-release" => {
        hal_dependency += "\n";
        hal_dependency += `version = "${hal_version}"`;
    }
    "git" => {
        hal_dependency += "\n";
        hal_dependency += `git = "https://github.com/stm32-rs/${hal}"`;
    }
}
hal_dependency += "\n";
hal_dependency += `features = ["${chipserie}", `;
if variable::get("rtic") {
    hal_dependency += "\"rtic\", "
}
hal_dependency += "]";


variable::set("target", target);
variable::set("chipserie", chipserie);
variable::set("CHIP", probe_rs_chip);
variable::set("hal", hal);
variable::set("hal_dependency", hal_dependency);
variable::set("hal_", hal_);
variable::set("itcm", itcm > 0);
variable::set("dtcm", dtcm > 0);
variable::set("memory_blocks", memory_blocks);