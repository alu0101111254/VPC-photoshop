
  void call_load_img(File selected) {
    menu.transform.load_image(selected);
  }
  
  void call_load_second_img(File selected) {
    menu.transform.load_second_image(selected);
  }
  

  
  public void draw_output() {
    int w_height = menu.transform.output_img.height > 600 ? menu.transform.output_img.height : 600;
    GWindow output =  GWindow.getWindow(this, "output image", 0, 0, 400 + menu.transform.output_img.width , w_height, JAVA2D);
    output.addDrawHandler(this, "draw_out_image");
  }

  
  public void draw_out_image(PApplet app, GWinData windata)  {
    menu.transform.draw_out_image(app);
    menu.transform.reload_histogram(app, menu.transform.output_img, (float)menu.transform.output_img.width, 0.0, 400.0, 280.0);
    menu.transform.reload_acc_histogram(app, menu.transform.output_img, (float)menu.transform.output_img.width, 300.0, 400.0, 280.0);
  }
  
  public void draw_second() {
    int w_height = menu.transform.second_img.height > 600 ? menu.transform.second_img.height : 600;
    GWindow output =  GWindow.getWindow(this, "second image", 0, 0, 400 + menu.transform.second_img.width , w_height, JAVA2D);
    output.addDrawHandler(this, "draw_second_image");
  }

  
  public void draw_second_image(PApplet app, GWinData windata)  {
    menu.transform.draw_second_image(app);
    menu.transform.reload_histogram(app, menu.transform.second_img, (float)menu.transform.second_img.width, 0.0, 400.0, 280.0);
    menu.transform.reload_acc_histogram(app, menu.transform.second_img, (float)menu.transform.second_img.width, 300.0, 400.0, 280.0);
  }
  
  void input_gamma(PApplet app, GWinData windata) {
    app.textSize(25);
    app.text("Introduzca Valor gamma: ", 10, 30); 
    app.fill(0);
  }
  
  void input_threshold(PApplet app, GWinData windata) {
    app.textSize(20);
    app.text("Introduzca Valor umbral de diferencia: ", 10, 30); 
    app.fill(0);
  }
  
  void hist_point_input(PApplet app, GWinData windata) {
    app.background(200);
    app.textSize(20);
    app.text("Introduzca un punto en el histograma: ", 10, 30); 
    app.fill(0);
  }
  
  void value_input(PApplet app, GWinData windata) {
    app.background(200);
    app.textSize(20);
    app.text("Introduzca el valor del punto en el histograma: ", 10, 30); 
    app.fill(0);
  }
  
  void point_num_input(PApplet app, GWinData windata) {
    app.background(200);
    app.textSize(20);
    app.text("Introduzca el numero de puntos: ", 10, 30); 
    app.fill(0);
  }
  
  void image_name(PApplet app, GWinData windata) {
    app.background(200);
    app.textSize(20);
    app.text("Introduzca el nombre de la imagen: ", 10, 30); 
    app.fill(0);
  }
  
  
  public void fileCreate(File created){
    if (created == null) {
      println("Window was closed or the user hit cancel.");
    } else {
      menu.transform.img.save(created.getAbsolutePath());
    }
  }
  public void fileCreateOutput(File created){
    if (created == null) {
      println("Window was closed or the user hit cancel.");
    } else {
      menu.transform.output_img.save(created.getAbsolutePath());
    }
  }
  
  
  public void handleButtonEvents(GButton button, GEvent event) {
    if(event == GEvent.CLICKED){
      if (button == menu.open_img_btn) {
        selectInput("Select a file to process:", "call_load_img");
      } else if (button == menu.open_second_img_btn) {
        selectInput("Select a file to process:", "call_load_second_img");
     
      } else if (button == menu.change_brightness_btn) {
        menu.deactivate_all_flags();
        
        menu.brightness_input_flag = true;
        
        text_field =  GWindow.getWindow(this, "Input window", 100, 50, 500, 100, JAVA2D);
        GTextField x = new GTextField(text_field, 0, 50, 500, 50);
        text_field.addDrawHandler(this, "point_num_input");
      } else if (button == menu.equalize_hist_btn) {
        menu.transform.equalize_hist();
        
      } else if (button == menu.specify_hist_btn) {
        menu.transform.specify_hist();
      } else if (button == menu.get_diff_btn) {
        menu.transform.difference();
        draw_output();
      } else if (button == menu.show_diff_btn) {
        menu.deactivate_all_flags();
        
        menu.highlight_input_flag = true;
        
        text_field =  GWindow.getWindow(this, "Input window", 100, 50, 500, 100, JAVA2D);
        GTextField x = new GTextField(text_field, 0, 50, 500, 50);
        text_field.addDrawHandler(this, "input_threshold");
        
      } else if (button == menu.change_gamma_btn) {
        menu.deactivate_all_flags();
        
        menu.gamma_input_flag = true;
        
        text_field =  GWindow.getWindow(this, "Input window", 100, 50, 500, 100, JAVA2D);
        GTextField x = new GTextField(text_field, 0, 50, 500, 50);
        text_field.addDrawHandler(this, "input_gamma");
        
      } else if (button == menu.save_img_btn) {
          selectOutput("Eliga el nombre y formato de la imagen", "fileCreate");
     
      } else if (button == menu.save_output_btn) {
        selectOutput("Eliga el nombre y formato de la imagen", "fileCreateOutput");
     
      }
    
    }
    
  }
  
    public void handleTextEvents(GEditableTextControl textcontrol, GEvent event){
    if(event == GEvent.ENTERED) {
      if(menu.highlight_input_flag) {
        menu.transform.highlight_difference(Integer.parseInt(textcontrol.getText()));
        draw_output();
        menu.highlight_input_flag = false;
        text_field.forceClose();
      }else if(menu.gamma_input_flag) {
        menu.transform.gamma_transform(Float.parseFloat(textcontrol.getText()));
        menu.gamma_input_flag = false;
        text_field.forceClose();
      } else if(menu.brightness_input_flag){
        if(menu.brightness_point >= 2) {
          if(menu.inputs_left > 0){
            if(menu.inputs_left % 2 == 0) {
              menu.points[menu.brightness_point - ((menu.inputs_left + 1) / 2)] = Integer.parseInt(textcontrol.getText());
              text_field.addDrawHandler(this, "value_input");
              
            } else {
              menu.values[menu.brightness_point - ((menu.inputs_left + 1) / 2)] = Integer.parseInt(textcontrol.getText());
              text_field.addDrawHandler(this, "hist_point_input");
            }
            menu.inputs_left--;
            if(menu.inputs_left == 0) {
              menu.transform.brightness(menu.brightness_point, menu.points, menu.values);
              menu.brightness_input_flag = false;
              text_field.forceClose();
            }
          }
        } else {
          menu.brightness_point = Integer.parseInt(textcontrol.getText());
         
          if(menu.brightness_point >= 2) {
            menu.inputs_left = menu.brightness_point * 2;
            menu.points = new int[menu.brightness_point];
            menu.values = new int[menu.brightness_point];
            text_field.addDrawHandler(this, "hist_point_input");
          }
          
        }
      }
      
      textcontrol.setText("");
    }
  };
