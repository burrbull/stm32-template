// we can see existing variables.
// note that template and Rhai variables are separate!
let chip = variable::get("chip").to_lower();

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
if chip.starts_with("stm32f4") {
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
            ram = 16+16;
            ram4 = 16;
            dtcm = 128;
        }
    }
    itcm = 16;
    backupram = 4;
    axi_address = 0x24000000;
    ram_address = 0x30000000;
    ram4_address = 0x38000000;
    backup_address = 0x38800000;
    */
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

variable::set("target", target);
variable::set("chipserie", chipserie);
variable::set("CHIP", probe_rs_chip);
variable::set("hal", hal);
variable::set("hal_version", hal_version);
variable::set("hal_", hal_);
variable::set("itcm", itcm > 0);
variable::set("dtcm", dtcm > 0);
variable::set("memory_blocks", memory_blocks);