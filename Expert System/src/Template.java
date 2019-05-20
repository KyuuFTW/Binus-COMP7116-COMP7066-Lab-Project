import java.awt.BorderLayout;
import java.awt.Component;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.Font;
import java.awt.Graphics2D;
import java.awt.GridLayout;
import java.awt.Image;
import java.awt.RenderingHints;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.util.Vector;

import javax.imageio.ImageIO;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.table.DefaultTableModel;

import jess.JessException;
import jess.QueryResult;
import jess.ValueVector;
import projek.Main;


public class Template extends JFrame
{	
	JPanel content_panel = new JPanel(new FlowLayout(FlowLayout.CENTER, 30, 30));
	
	JButton btnClose = new JButton("Close");
	
	String userName = "";
	String userGender = "";
	String userIncome = "";
	String userWorkLocation = "";
	String userHouseInterest = "";
	String userHouseType = "";
	String userPreferedGarageNumber = "";
	
	Vector<String> header = new Vector<String>();
	Vector<Vector<String>> data = new Vector<Vector<String>>();
	Vector<String> row;
	
	DefaultTableModel defaultTableModel;
	JTable table;
	JScrollPane scrollPane;
	
	final Template frame = this;
	
	public void initComponents()
	{
		getContentPane().setLayout(new BorderLayout());
		
		JLabel lblTitle = new JLabel("No Match Found!", JLabel.CENTER);
		lblTitle.setFont(new Font(Font.MONOSPACED, Font.BOLD, 21));
		getContentPane().add(lblTitle, BorderLayout.NORTH);
		
		JPanel left_panel = new JPanel(new BorderLayout());
		JLabel lblHeader = new JLabel("Your Profile");
		lblHeader.setFont(new Font(Font.MONOSPACED, Font.BOLD, 15));
		left_panel.add(lblHeader, BorderLayout.NORTH);
		
		//Panel that contain all house's info
		JPanel grid_panel = new JPanel(new GridLayout(7, 2));
		
		JLabel lblName = new JLabel("Name : ");
		JLabel lblGender = new JLabel("Gender : ");
		JLabel lblIncome = new JLabel("Income : ");
		JLabel lblInterest = new JLabel("House Interest : ");
		JLabel lblHouseLocation = new JLabel("Prefered House Location: ");
		JLabel lblHouseType = new JLabel("Prefered House Type: ");
		JLabel lblCarNumber = new JLabel("Prefered Garage Size:  ");

		//Labels that contain house's info
		JLabel lblNameInfo = new JLabel();
		JLabel lblInterestInfo = new JLabel();
		JLabel lblTypeInfo = new JLabel();
		JLabel lblGenderInfo = new JLabel();
		JLabel lblPriceInfo = new JLabel();
		JLabel lblLocationInfo = new JLabel();
		JLabel lblGarageNumberInfo = new JLabel();
		
		try
		{
			// Query Result Code Here
			QueryResult resultMatchHouse = Main.engine.runQueryStar("get-info", new ValueVector());
			if(resultMatchHouse.next())
			{
				userName = resultMatchHouse.getString("name");
				userGender = resultMatchHouse.getString("gender");
				userHouseInterest = resultMatchHouse.getString("interest");
				userWorkLocation = resultMatchHouse.getString("location");
				userIncome = resultMatchHouse.getString("income");
				userHouseType = resultMatchHouse.getString("type");
				userPreferedGarageNumber = resultMatchHouse.getString("carCount");
				
				lblNameInfo.setText(userName);
				lblGenderInfo.setText(userGender);
				lblInterestInfo.setText(userHouseInterest);
				lblTypeInfo.setText(userHouseType);
				lblPriceInfo.setText(userIncome);
				lblLocationInfo.setText(userWorkLocation);
				lblGarageNumberInfo.setText(userPreferedGarageNumber);
				
				
				if(userHouseInterest.equals("Without Garage"))
				{
					lblCarNumber.hide();
					lblGarageNumberInfo.hide();
				}
			}
			
			resultMatchHouse.close();
		}
		catch (JessException e)
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		//Object that can be used as panel that contain image or table
		Object panel_add = null;
		
		//No match found
		panel_add = imageNotAvailable();
		
		/*Fill the code here to fetch all suitable match for user*/
		
		header.add("No.");
		header.add("House Type");
		header.add("House Room Number");
		header.add("House Price");
		header.add("House Location");
		if(userHouseInterest.equals("With Garage"))header.add("Garage Capacity");
		header.add("match-rate");
		
		defaultTableModel = new DefaultTableModel(data, header);
		table = new JTable(defaultTableModel);
		scrollPane = new JScrollPane(table);
		
		int index = 0;
		
		if(userHouseInterest.equals("With Garage"))
		{
			try
			{
				// Query Result Code Here
				QueryResult resultMatchWithGarage=Main.engine.runQueryStar("get-result", new ValueVector());
				while(resultMatchWithGarage.next())
				{
					index++;
					
					String type = resultMatchWithGarage.getString("type");
					String roomNumber = resultMatchWithGarage.getString("roomNumber");
					String price = resultMatchWithGarage.getString("price");
					String location = resultMatchWithGarage.getString("location");
					String garageNumber = resultMatchWithGarage.getString("number");
					String matchRate = resultMatchWithGarage.getString("match-rate");
					
					
					row = new Vector<String>();
					
					row.add(Integer.toString(index));
					row.add(type);
					row.add(roomNumber);
					row.add(price+" $USD");
					row.add(location);
					row.add(garageNumber);
					row.add(matchRate+"%");
					
					
					data.add(row);
				}
				
				resultMatchWithGarage.close();
				
				
			}
			catch (JessException e)
			{
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		else if(userHouseInterest.equals("Without Garage"))
		{
			try
			{
				// Query Result Code Here

				QueryResult resultMatchWithoutGarage=Main.engine.runQueryStar("get-result", new ValueVector());
				while(resultMatchWithoutGarage.next())
				{
					index++;
					
					String type = resultMatchWithoutGarage.getString("type");
					String roomNumber = resultMatchWithoutGarage.getString("roomNumber");
					String price = resultMatchWithoutGarage.getString("price");
					String location = resultMatchWithoutGarage.getString("location");
					String matchRate = resultMatchWithoutGarage.getString("match-rate");
				
					
					row = new Vector<String>();
					
					row.add(Integer.toString(index));
					row.add(type);
					row.add(roomNumber);
					row.add(price+" $USD");
					row.add(location);
					row.add(matchRate+"%");
				
					
					data.add(row);
				}
				
				resultMatchWithoutGarage.close();
				
				
			}
			catch (JessException e)
			{
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		if(data.size() != 0 )
		{
			panel_add = scrollPane;
			lblTitle.setText("Matches Found!");
		}
		
		grid_panel.add(lblName);
		grid_panel.add(lblNameInfo);
		
		grid_panel.add(lblGender);
		grid_panel.add(lblGenderInfo);
		
		grid_panel.add(lblInterest);
		grid_panel.add(lblInterestInfo);
		
		grid_panel.add(lblIncome);
		grid_panel.add(lblPriceInfo);
		
		grid_panel.add(lblHouseLocation);
		grid_panel.add(lblLocationInfo);
		
		grid_panel.add(lblHouseType);
		grid_panel.add(lblTypeInfo);
		
		grid_panel.add(lblCarNumber);
		grid_panel.add(lblGarageNumberInfo);
	
		
		left_panel.add(grid_panel, BorderLayout.CENTER);
		
		content_panel.add(left_panel);
		content_panel.add((Component) panel_add);
		content_panel.setPreferredSize(new Dimension (800, 450));
		
		getContentPane().add(content_panel, BorderLayout.CENTER);
		getContentPane().add(btnClose, BorderLayout.PAGE_END);
		
		btnClose.addActionListener(new ActionListener()
		{
			
			@Override
			public void actionPerformed(ActionEvent arg0)
			{
				frame.dispose();
			}
		});
	}
	
	private Image getScaledImage(Image srcImage, int width, int height)
	{
		BufferedImage resizedImage = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
		Graphics2D g2d = resizedImage.createGraphics();
		
		g2d.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BICUBIC);
		g2d.drawImage(srcImage, 0, 0, width, height, null);
		g2d.dispose();
		
		return resizedImage;
	}
	
	public JLabel imageNotAvailable()
	{
		JLabel lbl_img = new JLabel();
		lbl_img.setPreferredSize(new Dimension(320,180));
		Image bufferedImage;
		try
		{
			bufferedImage = ImageIO.read(getClass().getResource("not_available.jpg"));
			ImageIcon icon = new ImageIcon(getScaledImage(bufferedImage, 320, 180));
			lbl_img.setIcon(icon);
		}
		catch (IOException e)
		{
			return null;
		}
		return lbl_img;
	}
	
	public Template()
	{
		setTitle("The Result of Consultation");
		setSize(850, 450);
		setLocationRelativeTo(null);
		setDefaultCloseOperation(EXIT_ON_CLOSE);
		initComponents();
		setResizable(false);
		setVisible(true);
	}
}