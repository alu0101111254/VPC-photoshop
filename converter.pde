
import java.util.*;
// entropy
class converter {
  public PImage img;
  public PImage second_img;
  public PImage output_img;
  public String format;
  private int min_val;
  private int max_val;
  private int drawable_x;
  private int drawable_y;

  public converter() {
    drawable_x = round(width * 0.7);
    drawable_y = round(height * 0.95);
  }

  public void load_image(File selected) {
    if (selected == null) {
      println("Window was closed or the user hit cancel.");
    } else {
      img = loadImage(selected.getAbsolutePath());
      img = to_grayscale(img);
      String[] x = split(selected.getAbsolutePath(), ".");
      format = x[x.length - 1];
    }
    output_img = createImage(img.width, img.height, RGB);
    draw_image();
  }


  public void load_second_image(File selected) {
    if (selected == null) {
      println("Window was closed or the user hit cancel.");
    } else {
      second_img = loadImage(selected.getAbsolutePath());
      second_img = to_grayscale(second_img);
      draw_second();
    }
  }



  public PImage to_grayscale(PImage image) {

    for (int i = 0; i < image.pixels.length; i++) {
      image.pixels[i] = color(red(image.pixels[i]) * 0.299 + blue(image.pixels[i]) * 0.114 + green(image.pixels[i]) * 0.587);
    }
    return image;
  }  



  public PImage equalize_hist() {
    int[] Vout = new int[256];
    int[] acc_hist = new int[256];
    for (int i = 0; i < 256; i++) {
      acc_hist[i] = 0;
    }
    for (int i = 0; i < img.pixels.length; i++) {
      acc_hist[round(red(img.pixels[i]))]++;
    }

    for (int i = 1; i < 256; i++) {
      acc_hist[i] = acc_hist[i] + acc_hist[i - 1];
    }
    for (int i = 0; i < 256; i++) {
      int vout_val = round(((float)256  * (float)acc_hist[i]) / (float)img.pixels.length) - 1;
      Vout[i] = (vout_val > 0 ? vout_val : 0);
    }
    img = convert_to_table(Vout);
    return img;
  }


  public PImage specify_hist() {
    //primero convertir histogramas acumulativos en proporciones tal que acch= acch * 255/tamaño img
    // segundo vout[i] = acch2.find_valor_mas_cercano(acch[i])
    int[] Vout = new int[256];
    float[] acc_hist = new float[256];
    float[] acc_hist_2 = new float[256];
    for (int i = 0; i < 256; i++) {
      acc_hist[i] = 0;
      acc_hist_2[i] = 0;
    }
    for (int i = 0; i < img.pixels.length; i++) {
      acc_hist[round(red(img.pixels[i]))]++;
    }

    for (int i = 0; i < second_img.pixels.length; i++) {
      acc_hist_2[round(red(second_img.pixels[i]))]++;
    }

    for (int i = 1; i < 256; i++) {
      acc_hist[i] = acc_hist[i] + acc_hist[i - 1];
      acc_hist_2[i] = acc_hist_2[i] + acc_hist_2[i - 1];
    }
    for (int i = 0; i < acc_hist.length; i++) {
      acc_hist[i] = (acc_hist[i] * 255.0) / (float)img.pixels.length;
      acc_hist_2[i] = (acc_hist_2[i] * 255.0) / (float)second_img.pixels.length;
    }

    for (int i = 0; i < 256; i++) {
      Vout[i] = find_closest(acc_hist[i], acc_hist_2);
      print(Vout[i] + "\n");
    }
    img = convert_to_table(Vout);
    return img;
  }




  private int find_closest(float target, float[] search_array) {
    boolean found = false;
    int pos = search_array.length / 2; 
    while (!found) {
      if (target == search_array[pos]) {
        return pos;
      } else if (target >= search_array[pos] && target <= search_array[pos + 1]) {
        found = true;
      } else if (target <= search_array[pos] && target >= search_array[pos - 1]) {
        found = true;
      } else {
        pos = (target < search_array[pos] ? pos - 1 : pos + 1);
        if (pos == 255 || pos == 0) {
          return pos;
        }
      }
    }
    float diff_a;
    float diff_b;
    if (target >= search_array[pos] && target <= search_array[pos + 1]) {
      diff_a = target - search_array[pos];   
      diff_b = search_array[pos + 1] - target;
      pos = (diff_a < diff_b ? pos : pos + 1);
    } else {
      diff_b = target - search_array[pos - 1];   
      diff_a = search_array[pos] - target;
      pos = (diff_a < diff_b ? pos : pos - 1);
    }
    return pos;
  }



  public boolean grayscale_check() {
    for (int i = 0; i < img.pixels.length; i++) {
      if (red(img.pixels[i]) != blue(img.pixels[i]) || red(img.pixels[i]) != green(img.pixels[i])) {
        return false;
      }
    }
    return true;
  }



  public PImage brightness(int line_number, int[] points, int[] values) {
    int[] Vout = new int[256];

    if (line_number < 2 || points.length != values.length) {
      print("error in size");
      return img;
    } else if (points[0] != 0 || points[points.length - 1] != 255) {
      return img;
    }
    for (int i = 0; i < points.length - 1; i++) {
      float A = ((float)values[i + 1] - (float)values[i]) / (float)(points[i + 1] - (float)points[i]);
      float B = values[i] -  A * points[i];
      for (int j = points[i]; j < points[i + 1]; j++) {
        float Voutj = A * j + B;
        Vout[j] = round(Voutj);
      }
    }
    img = convert_to_table(Vout);
    return img;
  }

    public PImage highlight_difference(int umbral) {
    if(img.pixels.length != second_img.pixels.length) {
      return output_img;
    }
    for (int i = 0; i < second_img.pixels.length; i++) {
      output_img.pixels[i] = abs(red(img.pixels[i]) - red(second_img.pixels[i])) > umbral ?  color(255, 0, 0) : img.pixels[i];
    }

    return output_img;
  }



  public PImage difference() {
    if(img.pixels.length != second_img.pixels.length) {
      return output_img;
    }
    
    for (int i = 0; i < second_img.pixels.length; i++) {
      output_img.pixels[i] = img.pixels[i] - second_img.pixels[i];
    }

    return  output_img;
  }





  private PImage convert_to_table(int[] Vout) {
    PImage converted_img = img;
    for (int i = 0; i < converted_img.pixels.length; i++) {
      converted_img.pixels[i] = color((float)Vout[round(red(img.pixels[i]))]);
    }
    return converted_img;
  }

  public PImage gamma_transform(float gamma) {
    int[] Vout = new int[256];
    for (int i = 0; i < 256; i++) {
      int val = round(pow((((float)i) / 255.0), gamma) * 255);
      Vout[i] = (val > 255 ? 255 : val);
    }
    img = convert_to_table(Vout);
    return img;
  }

  public void draw_image() {
    float proportion = (float)img.height / img.width;
    if(proportion <= (float)drawable_y / drawable_x){
      image(img, width - drawable_x, height - drawable_y, drawable_x, drawable_x * proportion);
    } else {
      image(img, width - drawable_x, height - drawable_y, drawable_y / proportion, drawable_y);
    }
    
  }

  public void draw_out_image(PApplet app) {
    app.background(200);
    app.image(output_img, 0, 0);
  }
  
    public void draw_second_image(PApplet app) {
    app.background(200);
    app.image(second_img, 0, 0);
  }


  void reload_histogram(PApplet app, PImage image, float x, float y, float width_h, float height_h) {
    float[] values = new float[256];
    for (int i = 0; i < 256; i++) {
      values[i] = 0;
    }
    for (int i = 0; i < image.pixels.length; i++) {
      values[round(red(image.pixels[i]))]++;
    }
    BarChart histograma = new BarChart(app);
    histograma.setData(values);
    histograma.setBarColour(0); 
    histograma.showValueAxis(true);
    histograma.draw(x, y, width_h, height_h);
  }




  void reload_acc_histogram(PApplet app, PImage image, float x, float y, float width_h, float height_h) {
    float[] values = new float[256];
    for (int i = 0; i < 256; i++) {
      values[i] = 0;
    }
    for (int i = 0; i < image.pixels.length; i++) {
      values[round(red(image.pixels[i]))]++;
    }
    for (int i = 1; i < 256; i++) {
      values[i] += values[i - 1];
    }
    BarChart histograma = new BarChart(app);
    histograma.setData(values);
    histograma.setBarColour(0); 
    histograma.showValueAxis(true);
    histograma.draw(x, y, width_h, height_h);
  }




  public float get_brightness() {
    float sum = 0;
    for (int i = 0; i < img.pixels.length; i++) {
      sum += red(img.pixels[i]);
    }
    return sum / (float)img.pixels.length;
  }



  public float get_contrast() {
    float sum = 0;
    float mean = get_brightness();
    for (int i = 0; i < img.pixels.length; i++) {
      sum += pow(red(img.pixels[i]) - mean, 2);
    }
    return sqrt(sum / (float)img.pixels.length);
  }
  
  public float get_entropy() {
    float sum = 0;
    float[] values = new float[256];
    
    for (int i = 0; i < 256; i++) {
      values[i] = 0;
    }
    for (int i = 0; i < img.pixels.length; i++) {
      values[round(red(img.pixels[i]))]++;
    }
    
    for(int i = 0; i < 256; i++) {
      double val = values[i] / img.pixels.length;
      if(val != 0)  {
        double log = Math.log(val) / Math.log(2);
        sum += val * log;
      }
    }
    return sum * -1;
  }


  public String mouse_position_in_image() {
    int posX, posY;
    float proportion = (float)img.height / img.width;
    if(proportion <= (float)drawable_y / drawable_x){    
      if (((mouseX >= (width - drawable_x)) && (mouseY >= (height - drawable_y))) && ((mouseX < (width) && (mouseY < ((height - drawable_y + drawable_x * proportion) ))))) {
        posX = round((float)(mouseX - (int)(width - (drawable_x))) / ((float)drawable_x / (float)img.width));
        posY = round((float)(mouseY - (int)(height - (drawable_y))) / ((float)drawable_x * proportion / (float)img.height));
        String result = new String("Está en la imagen x : " + (posX + 1) + " y : " + (posY + 1) + "\nNivel de gris:" + red(img.get(posX, posY)));
        
        return result;
      }
    } else {
      if (((mouseX >= (width - drawable_x)) && (mouseY >= (height - drawable_y))) && ((mouseX < (width - drawable_x +  drawable_y / proportion) && (mouseY < height)))) {
        posX = round((float)(mouseX - (width - drawable_x) )/ (((float)drawable_y / proportion) / (float)img.width));
        posY = round((float)(mouseY - (height - drawable_y) )/ ((float)drawable_y / (float)img.height));
        String result = new String("Está en la imagen x : " + (posX + 1) + " y : " + (posY + 1) + "\nNivel de gris:" + red(img.get(posX, posY)));
        
        return result;
      }
    }
    return "";
  }

}
