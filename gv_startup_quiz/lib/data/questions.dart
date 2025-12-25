/// QUIZ QUESTIONS
/// Founders: You can edit, add, or remove questions here!
/// Each question has: question text, 4 options, and correct answer index (0-3)
/// 
/// IMPORTANT: Keep questions generic and educational.
/// Avoid: legal advice, financial promises, medical claims

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });
}

const List<QuizQuestion> quizQuestions = [
  QuizQuestion(
    question: "What does MVP stand for in startup terminology?",
    options: [
      "Most Valuable Player",
      "Minimum Viable Product",
      "Maximum Value Proposition",
      "Market Validation Process"
    ],
    correctIndex: 1,
    explanation: "MVP means Minimum Viable Product - the simplest version of your product that can be tested with real users.",
  ),
  QuizQuestion(
    question: "What is a 'pitch deck'?",
    options: [
      "A boat used by entrepreneurs",
      "A presentation to attract investors",
      "A type of office furniture",
      "A sales technique"
    ],
    correctIndex: 1,
    explanation: "A pitch deck is a brief presentation that gives investors an overview of your business plan.",
  ),
  QuizQuestion(
    question: "What does 'bootstrapping' mean in business?",
    options: [
      "Starting a shoe company",
      "Using computers to start a business",
      "Self-funding without external investment",
      "Hiring employees quickly"
    ],
    correctIndex: 2,
    explanation: "Bootstrapping means building a company using personal finances or operating revenues, without external funding.",
  ),
  QuizQuestion(
    question: "What is a 'pivot' in startup context?",
    options: [
      "A type of office chair",
      "Changing your business model or direction",
      "Rotating your logo",
      "Moving to a new office"
    ],
    correctIndex: 1,
    explanation: "A pivot is a fundamental change in business strategy while keeping the original vision.",
  ),
  QuizQuestion(
    question: "What does ROI stand for?",
    options: [
      "Return On Investment",
      "Rate Of Improvement",
      "Result Of Innovation",
      "Revenue Over Income"
    ],
    correctIndex: 0,
    explanation: "ROI measures the profitability of an investment relative to its cost.",
  ),
  QuizQuestion(
    question: "What is 'burn rate'?",
    options: [
      "How fast you can cook food",
      "The speed of internet connection",
      "How quickly a company spends money",
      "The rate of employee turnover"
    ],
    correctIndex: 2,
    explanation: "Burn rate is the rate at which a company uses up its cash reserves before generating positive cash flow.",
  ),
  QuizQuestion(
    question: "What is an 'angel investor'?",
    options: [
      "An investor from heaven",
      "A wealthy individual who invests in early-stage startups",
      "A government investment program",
      "A bank loan officer"
    ],
    correctIndex: 1,
    explanation: "Angel investors are high-net-worth individuals who provide capital for startups, often in exchange for equity.",
  ),
  QuizQuestion(
    question: "What does B2B mean?",
    options: [
      "Back to Business",
      "Business to Business",
      "Build to Buy",
      "Beyond the Budget"
    ],
    correctIndex: 1,
    explanation: "B2B describes companies that sell products or services to other businesses rather than consumers.",
  ),
  QuizQuestion(
    question: "What is a 'unicorn' company?",
    options: [
      "A company that sells toys",
      "A startup valued at over \$1 billion",
      "A company with a horse logo",
      "A rare type of partnership"
    ],
    correctIndex: 1,
    explanation: "A unicorn is a privately held startup company valued at over \$1 billion.",
  ),
  QuizQuestion(
    question: "What is 'equity' in a company?",
    options: [
      "The company's debt",
      "Ownership stake or shares",
      "The company's expenses",
      "Employee salaries"
    ],
    correctIndex: 1,
    explanation: "Equity represents ownership interest in a company, usually in the form of shares.",
  ),
  QuizQuestion(
    question: "What is a 'business model'?",
    options: [
      "A fashion show for entrepreneurs",
      "How a company creates and captures value",
      "A 3D model of your office",
      "A type of company structure"
    ],
    correctIndex: 1,
    explanation: "A business model describes how a company creates, delivers, and captures value.",
  ),
  QuizQuestion(
    question: "What does 'scalability' mean?",
    options: [
      "Weighing products",
      "Ability to grow without proportional cost increase",
      "Fish-related business",
      "Climbing mountains"
    ],
    correctIndex: 1,
    explanation: "Scalability is the ability of a business to grow revenue without a corresponding increase in costs.",
  ),
  QuizQuestion(
    question: "What is 'market validation'?",
    options: [
      "Checking if a market exists",
      "Getting a parking validation",
      "Testing if customers want your product",
      "Approving a shopping mall"
    ],
    correctIndex: 2,
    explanation: "Market validation is the process of determining whether there's demand for your product before fully building it.",
  ),
  QuizQuestion(
    question: "What is a 'value proposition'?",
    options: [
      "A marriage proposal with money",
      "The unique value your product offers customers",
      "A discount offer",
      "A tax deduction"
    ],
    correctIndex: 1,
    explanation: "A value proposition is a clear statement of the tangible results a customer gets from using your product.",
  ),
  QuizQuestion(
    question: "What does 'runway' mean for startups?",
    options: [
      "Fashion show path",
      "Airport landing strip",
      "Time until money runs out",
      "Office hallway"
    ],
    correctIndex: 2,
    explanation: "Runway is the amount of time a company can operate before it runs out of money, usually measured in months.",
  ),
  QuizQuestion(
    question: "What is 'customer acquisition cost' (CAC)?",
    options: [
      "The cost of a customer's purchase",
      "Cost to gain a new customer",
      "Customer complaint handling cost",
      "Cost of customer service"
    ],
    correctIndex: 1,
    explanation: "CAC is the total cost of acquiring a new customer, including marketing and sales expenses.",
  ),
  QuizQuestion(
    question: "What is a 'co-founder'?",
    options: [
      "Someone who finds things with you",
      "A partner who starts a company with you",
      "A coffee maker",
      "A second office location"
    ],
    correctIndex: 1,
    explanation: "A co-founder is a person who helps establish a company alongside other founders.",
  ),
  QuizQuestion(
    question: "What does 'traction' mean in startup terms?",
    options: [
      "Vehicle performance",
      "Evidence of market demand or growth",
      "Pulling heavy objects",
      "Medical treatment"
    ],
    correctIndex: 1,
    explanation: "Traction refers to the evidence that a startup is gaining momentum, like user growth or revenue.",
  ),
  QuizQuestion(
    question: "What is 'due diligence'?",
    options: [
      "Working overtime",
      "Investigation before a business deal",
      "Following traffic rules",
      "Employee performance review"
    ],
    correctIndex: 1,
    explanation: "Due diligence is the comprehensive investigation of a business before signing a contract or investment.",
  ),
  QuizQuestion(
    question: "What is an 'exit strategy'?",
    options: [
      "Building fire exits",
      "How founders/investors will eventually cash out",
      "Employee resignation process",
      "Office evacuation plan"
    ],
    correctIndex: 1,
    explanation: "An exit strategy is a planned approach to transitioning ownership, like an acquisition or IPO.",
  ),
];
