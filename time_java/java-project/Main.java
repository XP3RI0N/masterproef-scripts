public class Main {

	public static void main(String[] args) {
		int i = 0;
		while (true) {
			try {
				System.out.println(i);
				i++;
				Thread.sleep(1000);
			} catch (Exception e) {
			}
		}
	}
}