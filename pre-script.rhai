// we can see existing variables.
// note that template and Rhai variables are separate!
let chip = variable::get("chip").to_lower();

let ram_address = "0x20000000";
let ccram_address = "0x10000000";
let flash_address = "0x08000000";
let flash_size_lit = chip[10];
let flash_size = switch flash_size_lit.to_upper() {
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

let hal;
let chipserie;
let chipfamily;
let ccram_size = 0;
let ram_size;
if chip.starts_with("stm32f4") {
    hal = "stm32f4xx-hal";
    chipfamily = "stm32f4";
    chipserie = chip.sub_string(0,9);
    switch chipserie {
        "stm32f401" => {
            ram_size = switch flash_size {
                128 | 256 => 64,
                384 | 512 => 96,
            };
        }
        "stm32f405" | "stm32f407" | "stm32f415" | "stm32f417" => {
            ram_size = 192;
        }
        "stm32f410" => {
            ram_size = 32;
        }
        "stm32f411" | "stm32f446" => {
            ram_size = 128;
        }
        "stm32f412" | "stm32f427" | "stm32f429" | "stm32f437" | "stm32f439" => {
            ram_size = 256;
        }
        "stm32f413" | "stm32f423" => {
            ram_size = 320;
        }
        "stm32f467" | "stm32f479" => {
            ram_size = 384;
        }
        _ => throw "Unknown RAM size",
    }
} else {
    throw "Unknown chip";
};
ram_size -= ccram_size;
let hal_ = hal;

let probe_rs_chip = chip.sub_string(0,12).to_upper() + "x";

let target = "thumbv7em-none-eabihf";
hal_.replace("-", "_");
debug(`Microcontroller family: ${chipserie}`);

let memory_blocks = `  FLASH (rx) : ORIGIN = ${flash_address}, LENGTH = ${flash_size}K`;
if ccram_size > 0 {
    memory_blocks += "\n";
    memory_blocks += `  CCMRAM (rwx) : ORIGIN = ${ccram_address}, LENGTH = {ccram_size}K`
};
memory_blocks += "\n";
memory_blocks += `  RAM (rwx) : ORIGIN = ${ram_address}, LENGTH = ${ram_size}K`;

debug(`Linker memory blocks:
${memory_blocks}`);

variable::set("target", target);
variable::set("chipserie", chipserie);
variable::set("CHIP", probe_rs_chip);
variable::set("hal", hal);
variable::set("hal_", hal_);
variable::set("memory_blocks", memory_blocks);