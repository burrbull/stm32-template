use std::env;
use std::fs;
use std::io::Write;
use std::path::Path;

fn main() {
    // Retrieve the target chip series from the environment variable
    let target = env::var("CHIPSERIE").expect("CHIPSERIE not provided");

    let filename = format!("{}.svd.patched", target);
    let url = format!("https://stm32-rs.github.io/stm32-rs/{}", &filename);
    let output_path = Path::new(&filename);

    // Check if the file already exists
    if output_path.exists() {
        println!(
            "SVD file already exists at {:?}, skipping download.",
            output_path
        );
    } else {
        // Ensure the output directory exists
        if let Some(parent) = output_path.parent() {
            fs::create_dir_all(parent).expect("Failed to create directory for SVD file");
        }

        // Download the file
        println!("Downloading SVD file from {}...", url);
        let response = reqwest::blocking::get(&url).expect("Failed to fetch SVD file");
        let content = response.text().expect("Failed to read response body");

        // Write the downloaded content to the file
        let mut file = fs::File::create(output_path).expect("Failed to create SVD file");
        file.write_all(content.as_bytes())
            .expect("Failed to write SVD file");

        println!("SVD file saved to {:?}", output_path);
    }
}
