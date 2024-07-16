import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class text_image extends StatelessWidget {
  const text_image({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
                                    Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 17),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(17),
                    gradient: const LinearGradient(
                      begin: Alignment(-1, 0),
                      end: Alignment(1, 0),
                      colors: <Color>[Color(0xFF004942), Color(0xFF005C54), Color.fromARGB(176, 1, 143, 131), Color.fromARGB(156, 3, 218, 197)],
                      stops: <double>[0.331, 0.536, 0.821, 1],
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(19, 17, 21, 14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.fromLTRB(0, 1, 12, 1),
                                child: SizedBox(
                                  width: 110,
                                  child: Text(
                                    '13 May',
                                    style: GoogleFonts.getFont(
                                      'Exo 2',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 24,
                                      height: 1,
                                      color: const Color(0xFFFFFFFF),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 26,
                                padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0x1AFFFFFF)),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: 
                                SizedBox(
                                  width: 10,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 2,
                                        height: 2,
                                        child: Container(
                                          width: 1,
                                          height: 1,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle
                                          ),),

                                      ),
                                      
                                      const SizedBox(width: 1,),

                                      SizedBox(
                                        width: 2,
                                        height: 2,
                                        child: Container(
                                          width: 1,
                                          height: 1,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle
                                          ),),

                                      ),

                                      const SizedBox(width: 1,),

                                      SizedBox(
                                        width: 2,
                                        height: 2,
                                        child: Container(
                                          width: 1,
                                          height: 1,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle
                                          ),),

                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 0, 11),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Boring Day',
                              style: GoogleFonts.getFont(
                                'Exo 2',
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                                height: 1,
                                color: const Color(0xFFFFFFFF),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 7.7, 11),
                          child: Text(
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incidid unt ut labore et dolore magna aliqua. Ut enon ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dol.',
                            style: GoogleFonts.getFont(
                              'Exo 2',
                              fontWeight: FontWeight.w200,
                              fontSize: 14,
                              height: 1,
                              color: const Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.fromLTRB(0, 0, 6.8, 0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: const Color(0xFFE3E3E3),
                                      image: const DecorationImage(
                                        fit: BoxFit.contain,
                                        image: AssetImage("assets/images/image_not_found.png")
                                      ),
                                    ),
                                    child: Container(
                                      height: 73,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.fromLTRB(0, 0, 6.8, 0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: const Color(0xFFE3E3E3),
                                      image: const DecorationImage(
                                        fit: BoxFit.contain,
                                        image: AssetImage("assets/images/image_not_found.png")
                                      ),
                                    ),
                                    child: Container(
                                      height: 73,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.fromLTRB(0, 0, 6.8, 0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: const Color(0xFFE3E3E3),
                                      image: const DecorationImage(
                                        fit: BoxFit.contain,
                                        image: AssetImage("assets/images/image_not_found.png")
                                      ),
                                    ),
                                    child: Container(
                                      height: 73,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.fromLTRB(0, 0, 6.8, 0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: const Color(0xFFE3E3E3),
                                      image: const DecorationImage(
                                        fit: BoxFit.contain,
                                        image: AssetImage("assets/images/image_not_found.png")
                                      ),
                                    ),
                                    child: Container(
                                      height: 73,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: const Color(0xFFE3E3E3),
                                    image: const DecorationImage(
                                      fit: BoxFit.contain,
                                      image: AssetImage("assets/images/image_not_found.png")
                                    ),
                                  ),
                                  child: Container(
                                    height: 73,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
