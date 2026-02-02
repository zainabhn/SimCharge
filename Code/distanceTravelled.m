function dist = distanceTravelled(curr_zone,dest_zone, MP_dim, z)
    diff = dest_zone - curr_zone;
    dz=1.4*z;
    switch curr_zone
        case 1
            dist_mat = [0,      z,      2*z,    3*z,  z,      dz,     dz+z,   dz+2*z, 2*z,    dz+z,   2*dz,   2*dz+z, 3*z,    dz+2*z, z+2*dz, 3*dz    ];
        case 2
            dist_mat = [z,      0,      z,      2*z, dz,     z,      dz,     dz+z, dz+z,   2*z,    z+dz,   2*dz, 2*z+dz, 3*z,    2*z+dz, z+2*dz    ];
        case 3
            dist_mat = [2*z,    z,      0,      z, dz+z,   dz,     z,      dz, 2*dz,   dz+z,   2*z,    dz+z, 2*dz+z, 2*z+dz, 3*z,    2*z+dz    ];

        case 4
            dist_mat = [3*z,    2*z,      z,      0, dz+2*z, z+dz,     dz,     z, 2*z+dz, 2*dz,     dz+z,   2*z, 3*dz,   z+2*dz,   2*z+dz, 3*z   ];

        case 5
            dist_mat = [z,      dz,       z+dz,   2*z+dz, 0,      z,        2*z,    3*z,  z,      dz,       dz+z,   2*z+dz, 2*z,    2*z+dz,   2*dz,   z+2*dz   ];

        case 6
            dist_mat = [dz,     z,        dz,     z+dz, z,      0,        z,      2*z, dz,     z,        dz,     z+dz, z+dz,   2*z,      z+dz,   2*dz   ];
    
        case 7
            dist_mat = [z+dz,   dz,       z,     dz, 2*z,    z,        0,     z, z+dz,   dz,       z,     dz, 2*dz,   z+dz,     2*z,   z+dz   ];
         case 8
            dist_mat = [2*z+dz, z+dz,     dz,     z, 3*z,    2*z,      z,      0, 2*z+dz, z+dz,     dz,     z, 2*dz+z, 2*dz,     z+dz,   2*z       ];

        case 9
            dist_mat = [2*z,    z+dz,     2*dz,   z+2*dz, z,      dz,       z+dz,   2*z+dz,  0,      z,        2*z,    3*z,  z,      dz,       z+dz,   2*z+dz   ];

         case 10
            dist_mat = [z+dz,   2*z,      z+dz,   2*dz, dz,     z,        dz,     z+dz, z,      0,        z,      2*z, dz,     z,        dz,   z+dz        ];


         case 11
            dist_mat = [2*dz,   z+dz,     2*z,   z+dz, dz,     dz,       z,     dz, 2*z,    z,        0,      z, z+dz,   dz,       z,      dz        ];

         case 12
            dist_mat = [z+2*dz,   2*dz,     z+dz,    2*z, 2*z+dz,   z+dz,     dz,      z, 3*z,      2*z,      z,       0, 2*z+dz,   z+dz,     dz,      z      ];

        case 13
            dist_mat = [3*z,    2*z+dz,   2*dz,   z+2*dz,    2*z,    z+dz,     2*dz,   z+2*dz, z,      dz,       z+dz,   2*z+dz, 0,      z,        2*z,    3*z,      ];

        case 14
            dist_mat = [2*z+dz, 3*z,      2*z+dz, z+2*dz, z+dz,   2*z,      z+dz,   2*dz, dz,     z,        dz,     z+dz, z,      0,        z,      2*z,      ];

        case 15
            dist_mat = [z+2*dz, 2*z+dz,   3*z,   2*z+dz,   2*dz,   z+dz,     2*z,   z+dz, dz,     dz,       z,     dz, 2*z,    z,        0,      z,        ];

        case 16
            dist_mat = [3*dz,     z+2*dz,   2*z+dz,  3*z, z+2*dz,   2*dz,     z+dz,    2*z,  2*z+dz,   z+dz,     dz,      z,  3*z,      2*z,      z,       0,     ];

        
    end

    dist = dist_mat(dest_zone);
end
