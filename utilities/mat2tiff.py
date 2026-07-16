import os
import scipy.io
import imageio.v2 as imageio


def mat_to_tiff_stack(mat_file, variable_name, output_dir):
    """
    Load a 3D image array from a MATLAB (.mat) file and save each slice
    as an individual TIFF image.

    Parameters
    ----------
    mat_file : str
        Path to the MATLAB (.mat) file.
    variable_name : str
        Name of the image array stored in the .mat file.
    output_dir : str
        Directory where TIFF images will be saved.
    """

    # Load MATLAB file
    mat = scipy.io.loadmat(mat_file)
    print("Available variables:", mat.keys())

    # Extract the image volume
    image_volume = mat[variable_name]
    print("Image volume shape:", image_volume.shape)

    # Create the output directory if it does not exist
    os.makedirs(output_dir, exist_ok=True)

    # Save each slice as a TIFF image
    for slice_idx in range(image_volume.shape[2]):
        output_path = os.path.join(output_dir, f"{slice_idx}.tif")
        imageio.imwrite(output_path, image_volume[:, :, slice_idx])

    print(f"Saved {image_volume.shape[2]} TIFF images to '{output_dir}'.")