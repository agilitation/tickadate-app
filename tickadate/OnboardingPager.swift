import UIKit

class OnboardingPager : UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  
  var pages:[OnboardingViewController] = []
  
  
  override func viewDidLoad() {
    // Set the dataSource and delegate in code.
    // I can't figure out how to do this in the Storyboard!
    dataSource = self
    delegate = self
    // this sets the background color of the built-in paging dots
    view.backgroundColor = UIColor.darkGray
    
    // This is the starting point.  Start with step zero.
    
    pages =  [
      storyboard?.instantiateViewController(withIdentifier: "onboardingPage1") as! OnboardingViewController,
      storyboard?.instantiateViewController(withIdentifier: "onboardingPage2") as! OnboardingViewController,
      storyboard?.instantiateViewController(withIdentifier: "onboardingPage3") as! OnboardingViewController,
      storyboard?.instantiateViewController(withIdentifier: "onboardingPage4") as! OnboardingViewController,
    ]
    
    setViewControllers([pages[0]], direction: .forward, animated: false, completion: nil)
  }
  
  func nextPage(fromViewController vc: UIViewController){
    self.setViewControllers([pageViewController(self, viewControllerAfter: vc)!], direction: .forward, animated: true) { (success) in
      print("done")
    }
    
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    if let index = pages.index(of: viewController as! OnboardingViewController), index > 0 {
      return pages[index - 1]
    }
    return nil
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    if let index = pages.index(of: viewController as! OnboardingViewController), index < pages.count - 1 {
      return pages[index + 1]
    }
    
    return nil
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    print("segue", segue)
  }
}
